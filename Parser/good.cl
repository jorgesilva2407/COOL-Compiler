class A {
};

Class BB__ inherits A {
};

class Person {
  name: String;
  age: Int;

  init(name: String, age: Int): Person {
    name = name;
    age = age;
  }

  say_hello() {
    print("Hello, my name is " + name);
  }
};

class Student inherits Person {
  school: String;

  init(name: String, age: Int, school: String) {
    super.init(name, age);
    school = school;
  }

  say_hello() {
    out_string("Hello, my name is ").out_string(name).out_string(" and I'm a student at ").out_string(school);
  }
};

class Calculator {
  num1: Int;
  num2: Int;

  init(num1_: Int, num2_: Int) {
    num1 = num1_;
    num2 = num2_;
  }

  add() {
    return num1 + num2;
  }

  subtract() {
    return num1 - num2;
  }

  multiply() {
    return num1 * num2;
  }

  divide() {
    return num1 / num2;
  }
};

class Main inherits IO {
    main() : SELF_TYPE {
	(let c : Complex <- (new Complex).init(1, 1) in
	    if c.reflect_X().reflect_Y() = c.reflect_0()
	    then out_string("=)\n")
	    else out_string("=(\n")
	    fi
	)
    };
};