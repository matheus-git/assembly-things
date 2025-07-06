use std::io::{self, Write};
use std::ffi::CString;

unsafe extern "C" {
    fn hello();
    fn sum(a: usize, b: usize) -> usize;
    fn file_size(filename: *const i8) -> i64;
    fn shell();
}

fn main() {
    unsafe {
        loop {
            println!("Menu:");
            println!("1) Hello world");
            println!("2) Sum two numbers");
            println!("3) Get file size");
            println!("4) Exec Shell");
            println!("0) Exit");
            print!("Choose an option: ");
            io::stdout().flush().unwrap();

            let mut input = String::new();
            io::stdin().read_line(&mut input).unwrap();
            let choice = input.trim();

            match choice {
                "1" => {
                    hello();
                }
                "2" => {
                    println!("Enter two numbers:");
                    let mut a_str = String::new();
                    let mut b_str = String::new();
                    io::stdin().read_line(&mut a_str).unwrap();
                    io::stdin().read_line(&mut b_str).unwrap();
                    let a = a_str.trim().parse::<usize>().unwrap_or(0);
                    let b = b_str.trim().parse::<usize>().unwrap_or(0);
                    let result = sum(a, b);
                    println!("Sum result: {}", result);
                }
                "3" => { 
                    println!("Enter filename:");
                    let mut filename_input = String::new();
                    io::stdin().read_line(&mut filename_input).unwrap();
                    let filename_trimmed = filename_input.trim_end();
                    let filename_cstring = CString::new(filename_trimmed).expect("CString::new failed");
                    let size = file_size(filename_cstring.as_ptr());
                    if size < 0 {
                        println!("File not found");
                    } else {
                        println!("Size: {}", size);
                    }
                }
                "4" => {
                   shell();
                }
                "0" => break,
                _ => println!("Invalid option"),
            }

            println!();
        }
    }
}
