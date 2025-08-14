use mysql::{params, prelude::*};
use actix_web::{cookie::Key, http::StatusCode};
use derive_more::{Display, Error, From};
use serde::{Deserialize};
use sha2::{Digest, Sha256};

#[derive(Debug, Display, Error, From)]
pub enum PersistenceError {
    UsernameAlreadyTaken,
    EmailAlreadyTaken,

    WrongCredentials,

    MysqlError(mysql::Error),

    Unknown,
}

impl actix_web::ResponseError for PersistenceError {
    fn status_code(&self) -> StatusCode {
        match self {
            PersistenceError::UsernameAlreadyTaken
            | PersistenceError::EmailAlreadyTaken => {
                StatusCode::CONFLICT
            },

            PersistenceError::WrongCredentials => {
                StatusCode::UNAUTHORIZED
            },

            _ => actix_web::http::StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

pub(crate) fn register(
    pool: &mysql::Pool,
    register_data: RegisterData,
) -> Result<(), PersistenceError> {

    let mut conn = pool.get_conn()?;

    if check_username_exists(&mut conn, register_data.username.clone()) {
        return Err(PersistenceError::UsernameAlreadyTaken);
    }

    if check_email_exists(&mut conn, register_data.email.clone()) {
        return Err(PersistenceError::EmailAlreadyTaken);
    }
    

    let user_id = insert_user(
        &mut conn,
        register_data.username,
        register_data.password,
        register_data.email,
        register_data.birthdate,
        register_data.firstname,
        register_data.lastname,
    )?;

    if user_id > 0 {
        Ok(())
    } else {
        Err(PersistenceError::Unknown)
    }
}

pub(crate) fn login(
    pool: &mysql::Pool,
    login_data: LoginData,
) -> Result<(), PersistenceError> {
    let mut conn = pool.get_conn()?;

    let user_id = get_user_id_by_username(&mut conn, login_data.username.clone())?;

    let session_token;
    
    while {
        let session_token = Key::from(&[0; 512]);
        let session_token = String::from(session_token);

        let session_hash = Sha256::digest(session_token.clone());
        
        check_session_token_exists(&mut conn, session_hash)
    } {}

    let expires_at = chrono::Utc::now()
        .checked_add_signed(chrono::Duration::days(1))
        .unwrap()
        .to_rfc3339();

    let result = insert_user_session(&mut conn, user_id, session_token, expires_at)?;


    if result > 0 {
        Ok(session_token)
    } else {
        Err(PersistenceError::Unknown)
    }
}

/* pub(crate) async fn logout(
    web::Json(logout_data): web::Json<LogoutData>,
    data: web::Data<mysql::Pool>,
) -> Result<(), mysql::Error> {

} */

// users table related
#[derive(Debug, Deserialize)]
pub struct RegisterData {
    pub username:   String,
    pub password:   String,
    pub email:      String,
    pub birthdate:  String,
    pub firstname:  String,
    pub lastname:   String,
}

fn insert_user(
    conn: &mut mysql::PooledConn,
    username:   String,
    password:   String,
    email:      String,
    birthdate:  String,
    firstname:  String,
    lastname:   String,
) -> mysql::error::Result<u64> {
    conn.exec_drop(
        "INSERT INTO users (username, password, email, birthdate, firstname, lastname)
        VALUES (:username, :password, :email, :birthdate, :firstname, :lastname)",
        params! {
            "username"  => username,
            "password"  => password,
            "email"     => email,
            "birthdate" => birthdate,
            "firstname" => firstname,
            "lastname"  => lastname,
        },
    ).map(|_| conn.last_insert_id())
}

fn get_user_id_by_username(
    conn: &mut mysql::PooledConn,
    username: String,
) -> mysql::error::Result<u64> {
    conn.exec_first(
        "SELECT id FROM users WHERE username = :username",
        params! {
            "username" => username,
        }
    ).map(Option::unwrap)
}

fn check_username_exists(
    conn: &mut mysql::PooledConn,
    username: String,
) -> bool {
    conn.exec_first(
        "SELECT EXISTS(SELECT username FROM users WHERE username = :username)",
        params! {
            "username" => username,
        },
    ).map(|result: Option<(u8,)>| result.map_or(false, |(exists,)| exists == 1))
        .unwrap_or(false)
}

fn check_email_exists(
    conn: &mut mysql::PooledConn,
    email: String,
) -> bool {
    conn.exec_first(
        "SELECT EXISTS(SELECT email FROM users WHERE email = :email)",
        params! {
            "email" => email,
        },
    ).map(|result: Option<(u8,)>| result.map_or(false, |(exists,)| exists == 1))
        .unwrap_or(false)
}

// Login and logout related
#[derive(Debug, Deserialize)]
pub struct LoginData {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Deserialize)]
pub struct LogoutData {
    pub session_id: String,
    pub username: String,
}

fn insert_user_session (
    conn: &mut mysql::PooledConn,
    user_id: u64,
    session_token: String,
    expires_at: String,
) -> mysql::error::Result<u64> {
    conn.exec_drop(
        "INSERT INTO user_sessions (user_id, session_token, expires_at)
        VALUES (:user_id, :session_token, :expires_at)",
        params! {
            "user_id"       => user_id,
            "session_token" => session_token,
            "expires_at"    => expires_at,
        },
    ).map(|_| conn.last_insert_id())
}

fn check_session_token_exists(
    conn: &mut mysql::PooledConn,
    session_token: String,
) -> bool {
    conn.exec_first(
        "SELECT EXISTS(SELECT session_token FROM users WHERE session_token = :session_token)",
        params! {
            "session_token" => session_token,
        },
    ).map(|result: Option<(u8,)>| result.map_or(false, |(exists,)| exists == 1))
        .unwrap_or(false)
}
