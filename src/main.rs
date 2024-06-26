use actix_web::{middleware, web, App, HttpRequest, HttpServer};

async fn say_hello(req: HttpRequest) -> &'static str {
    println!("REQ: {:?}", req);
    "Hello world!"
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Entered main ....");

    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    HttpServer::new(|| {
        App::new()
            // enable logger
            .wrap(middleware::Logger::default())
            .service(web::resource("/").to(say_hello))
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::body::to_bytes;
    use actix_web::dev::Service;
    use actix_web::{http, test, web, App, Error};

    #[actix_web::test]
    async fn test_say_hello() -> Result<(), Error> {
        let app = App::new().route("/", web::get().to(say_hello));
        let app = test::init_service(app).await;

        let req = test::TestRequest::get().uri("/").to_request();
        let resp = app.call(req).await.unwrap();

        assert_eq!(resp.status(), http::StatusCode::OK);

        let response_body = resp.into_body();
        assert_eq!(to_bytes(response_body).await.unwrap(), r##"Hello world!"##);

        Ok(())
    }
}