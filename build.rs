use std::process::Command;

fn main() {
    let sources = ["asm/hello.s"];

    for source in sources {
        let output = source.replace(".s", ".o");
        Command::new("gcc")
            .args(["-c", "-fPIC", source, "-o", &output])
            .status()
            .expect("GGGssssssssssemblesalfd");
        println!("cargo:rustc-link-arg={}", output);
    }
}
