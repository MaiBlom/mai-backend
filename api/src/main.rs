use std::env;
use actix_web::{web, App, HttpServer};
mod controllers {
    pub mod user_controller;
    pub mod scoreboard_controller;
}

fn api_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api")
            .configure(controllers::user_controller::user_routes)
            .configure(controllers::scoreboard_controller::scoreboard_routes),
    );
}

fn get_conn_builder(
    db_user: String,
    db_password: String,
    db_host: String,
    db_port: u16,
    db_name: String,
) -> mysql::OptsBuilder {
    mysql::OptsBuilder::new()
        .ip_or_hostname(Some(db_host))
        .tcp_port(db_port)
        .db_name(Some(db_name))
        .user(Some(db_user))
        .pass(Some(db_password))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenvy::dotenv().ok();

    log::info!("setting up app from environment");

    // api environment variables
    let server_addr = env::var("SERVER_ADDR").expect("SERVER_ADDR is not set");

    // db environment variables
    let db_user = env::var("MYSQL_USER")
        .expect("MYSQL_USER is not set in .env file");
    let db_password = env::var("MYSQL_PASSWORD")
        .expect("MYSQL_PASSWORD is not set in .env file");
    let db_host = env::var("MYSQL_HOST")
        .expect("MYSQL_HOST is not set in .env file");
    let db_port = env::var("MYSQL_PORT")
        .expect("MYSQL_PORT is not set in .env file");
    let db_port: u16 = db_port.parse().unwrap();
    let db_name = env::var("MYSQL_DBNAME")
        .expect("MYSQL_DBNAME is not set in .env file");

    let builder = get_conn_builder(db_user, db_password, db_host, db_port, db_name);

    let pool = mysql::Pool::new(builder).unwrap();
    let shared_database = web::Data::new(pool);

    HttpServer::new(|| {
        App::new()
            .app_data(shared_database.clone())
            .configure(api_routes)
    }).bind(server_addr)?
        .run()
        .await
}