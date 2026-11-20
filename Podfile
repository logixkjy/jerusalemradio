platform :ios, '17.6'

target 'jerusalemradio' do
  # Keep application diagnostics enabled; third-party source warnings are recorded
  # separately in tests/warnings_validation.txt and owned by the upstream pods.
  inhibit_all_warnings!
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  # FirebaseCoreInternal is Swift and needs a module map for this dependency.
  pod 'GoogleUtilities', :modular_headers => true
  pod 'AFNetworking', '~> 3.0'
  pod 'SBJson4', '~> 4.0.1'
  pod 'Reachability', '~> 3.7.7'
  pod 'FMDB'
  pod 'AudioStreamPlayer'
end

# Older pods declare targets below the range supported by current Xcode.
post_install do |installer|
  # Legacy networking pods import an SDK-private IPv6 header directly.
  # netinet/in.h already provides these declarations. Reapply after reinstalls.
  legacy_sources = [
    'AudioStreamPlayer/AudioStreamPlayer/Classes/STKAutoRecoveringHTTPDataSource.m',
    'AFNetworking/AFNetworking/AFNetworkReachabilityManager.m',
    'AFNetworking/AFNetworking/AFHTTPSessionManager.m'
  ]
  legacy_sources.each do |relative_path|
    source = installer.sandbox.root + relative_path
    next unless source.exist?

    original = source.read
    patched = original.gsub(/^#import <netinet6\/in6\.h>\r?\n/, '')
    next if patched == original

    File.chmod(0644, source)
    source.write(patched)
  end

  minimum_ios = Gem::Version.new('17.6')
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Some upstream category-only objects intentionally contain no symbols.
      libtool_flags = config.build_settings['OTHER_LIBTOOLFLAGS'] || ['$(inherited)']
      libtool_flags = [libtool_flags] unless libtool_flags.is_a?(Array)
      config.build_settings['OTHER_LIBTOOLFLAGS'] = (libtool_flags + ['-no_warning_for_no_symbols']).uniq
      declared_ios = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      if declared_ios && Gem::Version.new(declared_ios) < minimum_ios
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = minimum_ios.to_s
      end
    end
  end
end
