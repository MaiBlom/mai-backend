use actix_web::{web, HttpResponse};

pub fn scoreboard_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/scoreboard")
            .route("/get", web::to(|| async { HttpResponse::Ok().body("Get Scoreboard") }))
            .route("/update", web::to(|| async { HttpResponse::Ok().body("Update Scoreboard") })),
    );
}