class A {
};

Class BB__ inherits A {
};

class Person {
  name: String;
  age: Int;

  init(name: String, age: Int): Person {
    this.name = name;
    this.age = age;
  }

  say_hello() {
    print("Hello, my name is " + this.name);
  }
};

class Student inherits Person {
  school: String;

  init(name: String, age: Int, school: String) {
    super.init(name, age);
    this.school = school;
  }

  say_hello() {
    print("Hello, my name is " + this.name + " and I'm a student at " + this.school);
  }
};

class Calculator {
  num1: Int;
  num2: Int;

  init(num1: Int, num2: Int) {
    this.num1 = num1;
    this.num2 = num2;
  }

  add() {
    return this.num1 + this.num2;
  }

  subtract() {
    return this.num1 - this.num2;
  }

  multiply() {
    return this.num1 * this.num2;
  }

  divide() {
    return this.num1 / this.num2;
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