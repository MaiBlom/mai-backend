use actix_web::{web, HttpResponse, Responder};

#[path = "../models/user_model.rs"] mod user_model;

pub fn user_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/user")
            .route("/register",     web::to(register))
            .route("/login",    web::to(login))
            .route("/logout",   web::to(logout)),
    );
}


async fn register(
    data: web::Data<mysql::Pool>,
    web::Json(register_data): web::Json<user_model::RegisterData>,
) -> actix_web::Result<impl Responder> {

    let _ = web::block(move || user_model::register( &data, register_data)).await?;

    Ok(HttpResponse::Created().body("User registered successfully"))
}

async fn login(
    data: web::Data<mysql::Pool>,
    web::Json(login_data): web::Json<user_model::LoginData>,
) -> actix_web::Result<impl Responder> {
     
    let _ = web::block(move || user_model::login(&data, login_data)).await?;

    Ok(HttpResponse::Ok().body("User logged in successfully"))
}

async fn logout() -> impl Responder {
    HttpResponse::Ok().body("Logout User")
}