import std.stdio;
import std.path;
import std.json;
import std.regex;
import std.functional;
import std.array : split;
int main(string[] args){
    if(args.length != 2){
        writeln("Wrong number of arguments.");
        return -1;
    }
    string new_name = dirName(args[1]) ~dirSeparator~ baseName(args[1],".txt")~".js";
    auto m = File(args[1]);
    if( !m.isOpen()){
        writeln("Can't read file ",args[1]); 
        return -1;
    }    
    auto f = File(new_name, "w");
    if( !f.isOpen()){
        writeln("Can't write file ",args[1]); 
        return -1;
    }
    dchar[] buffer;
    auto reg = ctRegex!(r"([A-G]|[a-g])(#|b)?m?"d);
    alias reg_a = unaryFun!("matchFirst(a,reg)");
    reg_a("s"d);
    while(m.readln(buffer) > 0){
        
    }
    JSONValue j;
    j.array = [];
    j ~= [1];
    writeln(new_name);
    return 0;
}
