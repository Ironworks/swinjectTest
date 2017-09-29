//: Playground - noun: a place where people can play

import Swinject

//An Assembly is a protocol that is provided a shared Container where service definitions can be
//Registered. The shared container will contain all service definitions from every Assembly
//registered to the assembler. 

protocol FooServiceProtocol {}
protocol BarServiceProtocol {}
protocol FooManagerProtocol {
    var service: FooServiceProtocol { get set }
    init(service: FooServiceProtocol)
}
protocol BarManagerProtocol {
    var service: BarServiceProtocol { get set }
    init(service: BarServiceProtocol)
}

class FooService: FooServiceProtocol { }
class BarService: BarServiceProtocol { }

final class FooManager: FooManagerProtocol {
    
    var service: FooServiceProtocol
    
    init(service: FooServiceProtocol) {
        self.service = service
    }
}

final class BarManager: BarManagerProtocol {
    
    var service: BarServiceProtocol
    
    init(service: BarServiceProtocol) {
        self.service = service
    }
    
}

class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FooServiceProtocol.self) { r in
            return FooService()
        }
        container.register(BarServiceProtocol.self) { r in
            return BarService()
        }
    }
}

class ManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FooManagerProtocol.self) { r in
            return FooManager(service: r.resolve(FooServiceProtocol.self)!)
        }
        container.register(BarManagerProtocol.self) { r in
            return BarManager(service: r.resolve(BarServiceProtocol.self)!)
        }
    }
}

//We have created 2 assemblies, 1 for services and one for managers. The ManagerAssembly leverages
//Service definitions registered in the service assembly. Using this pattern the ManagerAssembly
//doesn't care where the FooServiceProtocol and BarServiceProtocol are registered.

//Simple logging class, that can be configured with different log handlers
protocol LogHandler {
    func log(message: String)
}

class Logger {
    
    static var sharedInstance = Logger()
    
    var logHandlers = [LogHandler]()
    
    func addHandler(loghandler: LogHandler) {
        logHandlers.append(loghandler)
    }
    
    func log(message: String) {
        for logHandler in logHandlers {
            logHandler.log(message: message)
        }
    }
}

class ConsoleLogHandler: LogHandler {
    func log(message: String) {
        print(message)
    }
}

class FileLogHandler: LogHandler {
    func log(message: String) {
         print(message)
    }
}


//This singleton is accessed in global logging functions to make it easy to add logging anywhere
//without having to deal with injects
func logDebug(message: String) {
    Logger.sharedInstance.log(message: "Debug: \(message)")
}

//In order to configure the Logger sharedInstance in the Container we will need to resolve the 
//Logger after the container has been built. Using an Assembly you can keep the bootstrapping in the 
//Assembly

class LoggerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LogHandler.self, name: "console") { r in
            return ConsoleLogHandler()
        }
        container.register(LogHandler.self, name: "file") { r in
            return FileLogHandler()
        }
    }
    
    func loaded(resolver: Resolver) {
        Logger.sharedInstance.addHandler(loghandler: resolver.resolve(LogHandler.self, name: "console")!)
        Logger.sharedInstance.addHandler(loghandler: resolver.resolve(LogHandler.self, name: "file")!)
    }
}

//The assembler is responsible for managing the assembly instances in the container.
//Using the Assembler, the Container is only exposed to assemblies registered with the assembler and 
//only provides access via the Resolver protocol which limits registration access strictly to
//the assemblies.

//Create the assembler
let assembler = Assembler([
    ServiceAssembly(),
    ManagerAssembly()
    ])


//You can also lazy load
assembler.apply(assembly: LoggerAssembly())



//Now we can resolve any components from either assembly:
let fooManager = assembler.resolver.resolve(FooManagerProtocol.self)
let barManager = assembler.resolver.resolve(BarManagerProtocol.self)
let consoleLogger = assembler.resolver.resolve(LogHandler.self, name: "console")

print (consoleLogger)
