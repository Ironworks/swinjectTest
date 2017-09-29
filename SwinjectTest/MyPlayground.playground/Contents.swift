//: Playground - noun: a place where people can play

import UIKit
import Swinject


//Service = Protocol
//Component = Concrete Implementation of  service
//Factory = A functon/closure instatiating a component
//Container = A collection of component instances

var str = "Hello, playground"

protocol AnimalType {
    var name: String { get }
    func sound() -> String
    
}

class Cat: AnimalType {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func sound() -> String {
        return "Meow!"
    }
}

class Dog: AnimalType {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func sound() -> String {
        return "Woof!"
    }
}

class PetOwner {
    let pet: AnimalType
    
    init(pet: AnimalType) {
        self.pet = pet
    }
    
    func play() -> String {
        return "I'm playing with \(pet.name). \(pet.sound())"
    }
}


//Register components in the container.
//Initialiser Injection
let container = Container()
container.register(AnimalType.self) { _ in Cat(name: "Eric") }
container.register(PetOwner.self) { r in PetOwner(pet: r.resolve(AnimalType.self)!) }


let petOwner = container.resolve(PetOwner.self)!
print (petOwner.play())

//Named registrations, can register 2 or more components for a service type, and name them
//to differentiate
container.register(AnimalType.self, name: "cat") { _ in Cat(name: "Eric") }
container.register(AnimalType.self, name: "dog") { _ in Dog(name: "Fred") }

//Get service instances using name
let cat = container.resolve(AnimalType.self, name: "cat")!
let dog = container.resolve(AnimalType.self, name: "dog")!

print (cat.name)
print (cat is Cat)
print(dog.name)
print(dog is Dog)


//Registration with arguments
class Horse: AnimalType {
    let name: String
    let running: Bool
    
    convenience init(name: String) {
        self.init(name: name, running: false)
    }
    
    init(name: String, running: Bool) {
        self.name = name
        self.running = running
    }
    
    func sound() -> String {
        return "Whinny!"
    }
}

container.register(AnimalType.self) { _, name in
    Horse(name: name)
}

container.register(AnimalType.self) { _, name, running in
    Horse(name: name, running: running)
}

//Passing one argument
let animal1 = container.resolve(AnimalType.self, argument: "Ned")!
print(animal1.name)
print((animal1 as! Horse).running) //Prints false

//Passing 2 arguments
let animal2 = container.resolve(AnimalType.self, arguments: "CartHorse", true)!
print(animal2.name)
print((animal2 as! Horse).running) //Prints true

//Property Injection

protocol Animal {
    func sound() -> String
}

protocol Person {
    var pet: Animal? { get }
}

class Bugie: Animal {
    
    init() { }
    
    func sound() -> String {
        return "Cheep, Cheep!!"
    }
    
}

class PetOwner2: Person {
    var pet: Animal?
    
    init() { }
}

container.register(Animal.self) { _ in Bugie() }
container.register(Person.self) { r in
    let owner = PetOwner2()
    owner.pet = r.resolve(Animal.self)
    return owner
}

let john = container.resolve(Person.self)!
print(john.pet?.sound())

//Method Injection

protocol Person2: Person { }

class PetOwner3: Person2 {
    var pet: Animal?
    
    init() { }
    
    func setPet(pet: Animal) {
        self.pet = pet
    }
}

container.register(Person2.self) { _ in PetOwner3() }
    .initCompleted { r, p in
        let owner = p as! PetOwner3
        owner.setPet(pet: r.resolve(Animal.self)!)
}

let alice = container.resolve(Person2.self)!
print(alice.pet?.sound())


//Value Types
protocol AnotherAnimal {
    var name: String { get set }
}

struct Turtle: AnotherAnimal {
    var name: String
    
}

//The struct can be registered and resolved as follows: 
container.register(AnotherAnimal.self) { _ in Turtle(name: "Ninja") }

var turtle1 = container.resolve(AnotherAnimal.self)!
print(turtle1.name)

//Container Hierarchy
let parentContainer = Container()
parentContainer.register(AnimalType.self) { _ in Cat(name: "Eric") }
let childContainer = Container(parent: parentContainer)

let aCat = childContainer.resolve(AnimalType.self)
print (aCat != nil)
print (aCat?.sound())





