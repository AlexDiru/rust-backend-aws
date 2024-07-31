#[macro_use]
extern crate rocket;

use rand::distributions::{Alphanumeric, DistString};
use rand::Rng;
use rocket::response::stream::TextStream;
use rocket::tokio::time::{self, Duration};

#[get("/")]
fn index() -> &'static str {
    "Hello, Docker!"
}

#[get("/word-stream")]
fn word_stream() -> TextStream![String] {
    TextStream! {
        let mut interval = time::interval(Duration::from_secs(1));
        loop {
            let ret = Alphanumeric.sample_string(&mut rand::thread_rng(), 16);
            yield ret;
            interval.tick().await;
        }
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index, word_stream])
}