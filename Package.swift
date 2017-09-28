// Generated automatically by Perfect Assistant Application
// Date: 2017-09-28 03:18:50 +0000
import PackageDescription
let package = Package(
	name: "SpeedPlayer",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
		.Package(url: "https://github.com/SwiftORM/MySQL-StORM.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", Version(2,1,7)),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-SMTP.git", majorVersion: 1),
		.Package(url: "https://github.com/yaslab/CSV.swift.git", majorVersion: 2),
	]
)
