import CoreWLAN
import SecurityFoundation
import ArgumentParser
import os

@main
struct wicli: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract:"wifi tool",
        version: "0.0.3",
        subcommands: [Setfirst.self, Power.self],
        defaultSubcommand: Setfirst.self
        )
}
extension wicli {

    enum Powerstate: String, ExpressibleByArgument {
        case on, off
    }

    struct Power: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "handle wifi power")
        @Argument(help: "interface to handle")
        var interface: String
        @Argument(help: "on or off")
        var state: Powerstate

        mutating func run() throws {

            do{
                let client = CWWiFiClient.shared()
                let iface = client.interface(withName: interface)
                if(iface == nil) {
                    print("\(interface) not found, these are valid:")
                    for interface in client.interfaces()! {
                        print(" - \(interface.interfaceName!)")
                    }
                    return
                }
                switch state {
                case Powerstate.on:
                    try iface?.setPower(true)
                    print("\(interface) is now on.")
                case Powerstate.off:
                    try iface?.setPower(false)
                    print("\(interface) is now off.")
                }
                
            }
            catch {
                print(error.localizedDescription)
                if #available(macOS 11, *) {
                let logger = Logger(subsystem: "wicli", category: "network")
                logger.critical("\(error.localizedDescription.description, privacy: .public)")
                }
            }
            
        }
    }

    struct Setfirst: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "move network as preferred. (run in sudo)")
        @Argument(help: "interface to handle")
        var interface: String

        @Option(name: [.short, .customLong("ssid")],help: "ssid to be first.")
        var ssid: String
        mutating func run() throws {

            do{
                let client = CWWiFiClient.shared()
                let iface = client.interface(withName: interface)
                if(iface == nil) {
                    print("\(interface) not found, these are valid:")
                    for interface in client.interfaces()! {
                        print(" - \(interface.interfaceName!)")
                    }
                    return
                }

                let config = iface?.configuration()?.mutableCopy() as! CWMutableConfiguration
                let sequence: NSMutableOrderedSet = NSMutableOrderedSet(array: iface!.configuration()!.networkProfiles.array)

                let networks = sequence.array as! [CWNetworkProfile]
                let exist = networks.first(where: {$0.ssid == ssid})
                if(exist == nil)
                {
                    print("does not exist")
                    return
                }
                

                for a in sequence.array as! [CWNetworkProfile] {
                    if(a.ssid == ssid)
                    {
                        sequence.remove(a)
                        sequence.insert(a, at: 0)
                    }
                }

                config.networkProfiles = sequence

                try iface?.commitConfiguration(config, authorization: nil)
                print("Done!")
            }
            catch {
                print(error.localizedDescription)
                if #available(macOS 11, *) {
                let logger = Logger(subsystem: "wicli", category: "network")
                logger.critical("\(error.localizedDescription.description, privacy: .public)")
                }
            }
        }
    }
}
