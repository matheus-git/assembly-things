# Assembly things

![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white)

A study and showcase project focused on practicing Linux syscalls on the x86_64 architecture. It combines assembly language with Rust to demonstrate how to integrate low-level syscalls with high-level programming. 

```rust
...
println!("Menu:");
println!("1) Hello world");
println!("2) Sum two numbers");
println!("3) Get file size");
println!("4) Exec Shell");
println!("5) Write on memory");
println!("6) Map file to memory and edit");
println!("7) Fork current process");
println!("8) Execute 'ls' in child process");
println!("9) Hello from pipe");
println!("10) Duplicate stdout and write hello");
println!("11) Tcp server 127.0.0.1:4444");
println!("12) Bind shell 127.0.0.1:4444");
println!("13) Read from FIFO");
println!("14) Write to FIFO");
println!("0) Exit");
print!("Choose an option: ");
...
```
## 📝 License

This project is open-source under the MIT License.
