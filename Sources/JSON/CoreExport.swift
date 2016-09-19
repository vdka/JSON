
// NOTE(vdka): This allows us to seperate the modules in SwiftPM 
//  while keeping a single module for iOS through Carthage
#if !Xcode
  @_exported import JSONCore
#endif
