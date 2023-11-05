class A {
};

Class BB__ inherits A {
};

class Person {
  name: String;
  age: Int;

  init(name: String, age: Int): Person {
    
    {
        name = name;
        age = age;
        self;
    }
  };
};

class Student inherits Person {
  school: String;

  init(name: String, age: Int, school_: String) {
    {
        super.init(name, age);
        school = school_;
    }
  };

  print(): Object {
    out_string("Hello, my name is ").out_string(name).out_string(" and I'm a student at ").out_string(school);
  };
};

class Main inherits IO {
    main() : SELF_TYPE {
        (let s : Student <- (new Student).init("Steve", 21, "Stanford") in
            if isVoid(s)
            then out_string("Fail")
            else s.print()
            fi      
        )
    };
};