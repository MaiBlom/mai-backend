use actix_web::{web, HttpResponse, Responder};

pub fn user_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/user")
            .route("/register", web::to(register))
            .route("/login", web::to(login))
            .route("/logout", web::to(logout)),
    );
}

async fn register() -> impl Responder {
    HttpResponse::Ok().body("Register User")
}

async fn login() -> impl Responder {
    HttpResponse::Ok().body("Login User")
}

async fn logout() -> impl Responder {
    HttpResponse::Ok().body("Logout User")
}