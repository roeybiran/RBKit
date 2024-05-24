import Foundation

public struct URLResourceValuesWrapper {
  public var allValues: [URLResourceKey: Any]
  public var name: String?
  public var localizedName: String?
  public var isRegularFile: Bool?
  public var isDirectory: Bool?
  public var isSymbolicLink: Bool?
  public var isVolume: Bool?
  public var isPackage: Bool?
  public var isApplication: Bool?
  public var applicationIsScriptable: Bool?
  public var isSystemImmutable: Bool?
  public var isUserImmutable: Bool?
  public var isHidden: Bool?
  public var hasHiddenExtension: Bool?
  public var creationDate: Date?
  public var contentAccessDate: Date?
  public var contentModificationDate: Date?
  public var attributeModificationDate: Date?
  public var linkCount: Int?
  public var parentDirectory: URL?
  public var volume: URL?
  public var typeIdentifier: String?
  public var localizedTypeDescription: String?
  public var labelNumber: Int?
  public var localizedLabel: String?
  public var fileResourceIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)?
  public var volumeIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)?
  public var fileIdentifier: UInt64?
  public var fileContentIdentifier: Int64?
  public var preferredIOBlockSize: Int?
  public var isReadable: Bool?
  public var isWritable: Bool?
  public var isExecutable: Bool?
  public var fileSecurity: NSFileSecurity?
  public var isExcludedFromBackup: Bool?
  public var tagNames: [String]?
  public var path: String?
  public var canonicalPath: String?
  public var isMountTrigger: Bool?
  public var generationIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)?
  public var documentIdentifier: Int?
  public var addedToDirectoryDate: Date?
  public var quarantineProperties: [String: Any]?
  public var mayHaveExtendedAttributes: Bool?
  public var isPurgeable: Bool?
  public var isSparse: Bool?
  public var mayShareFileContent: Bool?
  public var fileResourceType: URLFileResourceType?
  public var directoryEntryCount: Int?
  public var volumeLocalizedFormatDescription: String?
  public var volumeTotalCapacity: Int?
  public var volumeAvailableCapacity: Int?
  public var volumeAvailableCapacityForImportantUsage: Int64?
  public var volumeAvailableCapacityForOpportunisticUsage: Int64?
  public var volumeResourceCount: Int?
  public var volumeSupportsPersistentIDs: Bool?
  public var volumeSupportsSymbolicLinks: Bool?
  public var volumeSupportsHardLinks: Bool?
  public var volumeSupportsJournaling: Bool?
  public var volumeIsJournaling: Bool?
  public var volumeSupportsSparseFiles: Bool?
  public var volumeSupportsZeroRuns: Bool?
  public var volumeSupportsCaseSensitiveNames: Bool?
  public var volumeSupportsCasePreservedNames: Bool?
  public var volumeSupportsRootDirectoryDates: Bool?
  public var volumeSupportsVolumeSizes: Bool?
  public var volumeSupportsRenaming: Bool?
  public var volumeSupportsAdvisoryFileLocking: Bool?
  public var volumeSupportsExtendedSecurity: Bool?
  public var volumeIsBrowsable: Bool?
  public var volumeMaximumFileSize: Int?
  public var volumeIsEjectable: Bool?
  public var volumeIsRemovable: Bool?
  public var volumeIsInternal: Bool?
  public var volumeIsAutomounted: Bool?
  public var volumeIsLocal: Bool?
  public var volumeIsReadOnly: Bool?
  public var volumeCreationDate: Date?
  public var volumeURLForRemounting: URL?
  public var volumeUUIDString: String?
  public var volumeName: String?
  public var volumeLocalizedName: String?
  public var volumeIsEncrypted: Bool?
  public var volumeIsRootFileSystem: Bool?
  public var volumeSupportsCompression: Bool?
  public var volumeSupportsFileCloning: Bool?
  public var volumeSupportsSwapRenaming: Bool?
  public var volumeSupportsExclusiveRenaming: Bool?
  public var volumeSupportsImmutableFiles: Bool?
  public var volumeSupportsAccessPermissions: Bool?
  public var volumeTypeName: String?
  public var volumeSubtype: Int?
  public var volumeMountFromLocation: String?
  public var isUbiquitousItem: Bool?
  public var ubiquitousItemHasUnresolvedConflicts: Bool?
  public var ubiquitousItemIsDownloading: Bool?
  public var ubiquitousItemIsUploaded: Bool?
  public var ubiquitousItemIsUploading: Bool?
  public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus?
  public var ubiquitousItemDownloadingError: NSError?
  public var ubiquitousItemUploadingError: NSError?
  public var ubiquitousItemDownloadRequested: Bool?
  public var ubiquitousItemContainerDisplayName: String?
  public var ubiquitousItemIsExcludedFromSync: Bool?
  public var ubiquitousItemIsShared: Bool?
  public var ubiquitousSharedItemCurrentUserRole: URLUbiquitousSharedItemRole?
  public var ubiquitousSharedItemCurrentUserPermissions: URLUbiquitousSharedItemPermissions?
  public var ubiquitousSharedItemOwnerNameComponents: PersonNameComponents?
  public var ubiquitousSharedItemMostRecentEditorNameComponents: PersonNameComponents?
  public var fileProtection: URLFileProtection?
  public var fileSize: Int?
  public var fileAllocatedSize: Int?
  public var totalFileSize: Int?
  public var totalFileAllocatedSize: Int?
  public var isAliasFile: Bool?

  public init(
    allValues: [URLResourceKey: Any] = [:],
    name: String? = nil,
    localizedName: String? = nil,
    isRegularFile: Bool? = nil,
    isDirectory: Bool? = nil,
    isSymbolicLink: Bool? = nil,
    isVolume: Bool? = nil,
    isPackage: Bool? = nil,
    isApplication: Bool? = nil,
    applicationIsScriptable: Bool? = nil,
    isSystemImmutable: Bool? = nil,
    isUserImmutable: Bool? = nil,
    isHidden: Bool? = nil,
    hasHiddenExtension: Bool? = nil,
    creationDate: Date? = nil,
    contentAccessDate: Date? = nil,
    contentModificationDate: Date? = nil,
    attributeModificationDate: Date? = nil,
    linkCount: Int? = nil,
    parentDirectory: URL? = nil,
    volume: URL? = nil,
    typeIdentifier: String? = nil,
    localizedTypeDescription: String? = nil,
    labelNumber: Int? = nil,
    localizedLabel: String? = nil,
    fileResourceIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)? = nil,
    volumeIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)? = nil,
    fileIdentifier: UInt64? = nil,
    fileContentIdentifier: Int64? = nil,
    preferredIOBlockSize: Int? = nil,
    isReadable: Bool? = nil,
    isWritable: Bool? = nil,
    isExecutable: Bool? = nil,
    fileSecurity: NSFileSecurity? = nil,
    isExcludedFromBackup: Bool? = nil,
    tagNames: [String]? = nil,
    path: String? = nil,
    canonicalPath: String? = nil,
    isMountTrigger: Bool? = nil,
    generationIdentifier: (any NSCopying & NSSecureCoding & NSObjectProtocol)? = nil,
    documentIdentifier: Int? = nil,
    addedToDirectoryDate: Date? = nil,
    quarantineProperties: [String: Any]? = nil,
    mayHaveExtendedAttributes: Bool? = nil,
    isPurgeable: Bool? = nil,
    isSparse: Bool? = nil,
    mayShareFileContent: Bool? = nil,
    fileResourceType: URLFileResourceType? = nil,
    directoryEntryCount: Int? = nil,
    volumeLocalizedFormatDescription: String? = nil,
    volumeTotalCapacity: Int? = nil,
    volumeAvailableCapacity: Int? = nil,
    volumeAvailableCapacityForImportantUsage: Int64? = nil,
    volumeAvailableCapacityForOpportunisticUsage: Int64? = nil,
    volumeResourceCount: Int? = nil,
    volumeSupportsPersistentIDs: Bool? = nil,
    volumeSupportsSymbolicLinks: Bool? = nil,
    volumeSupportsHardLinks: Bool? = nil,
    volumeSupportsJournaling: Bool? = nil,
    volumeIsJournaling: Bool? = nil,
    volumeSupportsSparseFiles: Bool? = nil,
    volumeSupportsZeroRuns: Bool? = nil,
    volumeSupportsCaseSensitiveNames: Bool? = nil,
    volumeSupportsCasePreservedNames: Bool? = nil,
    volumeSupportsRootDirectoryDates: Bool? = nil,
    volumeSupportsVolumeSizes: Bool? = nil,
    volumeSupportsRenaming: Bool? = nil,
    volumeSupportsAdvisoryFileLocking: Bool? = nil,
    volumeSupportsExtendedSecurity: Bool? = nil,
    volumeIsBrowsable: Bool? = nil,
    volumeMaximumFileSize: Int? = nil,
    volumeIsEjectable: Bool? = nil,
    volumeIsRemovable: Bool? = nil,
    volumeIsInternal: Bool? = nil,
    volumeIsAutomounted: Bool? = nil,
    volumeIsLocal: Bool? = nil,
    volumeIsReadOnly: Bool? = nil,
    volumeCreationDate: Date? = nil,
    volumeURLForRemounting: URL? = nil,
    volumeUUIDString: String? = nil,
    volumeName: String? = nil,
    volumeLocalizedName: String? = nil,
    volumeIsEncrypted: Bool? = nil,
    volumeIsRootFileSystem: Bool? = nil,
    volumeSupportsCompression: Bool? = nil,
    volumeSupportsFileCloning: Bool? = nil,
    volumeSupportsSwapRenaming: Bool? = nil,
    volumeSupportsExclusiveRenaming: Bool? = nil,
    volumeSupportsImmutableFiles: Bool? = nil,
    volumeSupportsAccessPermissions: Bool? = nil,
    volumeTypeName: String? = nil,
    volumeSubtype: Int? = nil,
    volumeMountFromLocation: String? = nil,
    isUbiquitousItem: Bool? = nil,
    ubiquitousItemHasUnresolvedConflicts: Bool? = nil,
    ubiquitousItemIsDownloading: Bool? = nil,
    ubiquitousItemIsUploaded: Bool? = nil,
    ubiquitousItemIsUploading: Bool? = nil,
    ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus? = nil,
    ubiquitousItemDownloadingError: NSError? = nil,
    ubiquitousItemUploadingError: NSError? = nil,
    ubiquitousItemDownloadRequested: Bool? = nil,
    ubiquitousItemContainerDisplayName: String? = nil,
    ubiquitousItemIsExcludedFromSync: Bool? = nil,
    ubiquitousItemIsShared: Bool? = nil,
    ubiquitousSharedItemCurrentUserRole: URLUbiquitousSharedItemRole? = nil,
    ubiquitousSharedItemCurrentUserPermissions: URLUbiquitousSharedItemPermissions? = nil,
    ubiquitousSharedItemOwnerNameComponents: PersonNameComponents? = nil,
    ubiquitousSharedItemMostRecentEditorNameComponents: PersonNameComponents? = nil,
    fileProtection: URLFileProtection? = nil,
    fileSize: Int? = nil,
    fileAllocatedSize: Int? = nil,
    totalFileSize: Int? = nil,
    totalFileAllocatedSize: Int? = nil,
    isAliasFile: Bool? = nil
  ) {
    self.allValues = allValues
    self.name = name
    self.localizedName = localizedName
    self.isRegularFile = isRegularFile
    self.isDirectory = isDirectory
    self.isSymbolicLink = isSymbolicLink
    self.isVolume = isVolume
    self.isPackage = isPackage
    self.isApplication = isApplication
    self.applicationIsScriptable = applicationIsScriptable
    self.isSystemImmutable = isSystemImmutable
    self.isUserImmutable = isUserImmutable
    self.isHidden = isHidden
    self.hasHiddenExtension = hasHiddenExtension
    self.creationDate = creationDate
    self.contentAccessDate = contentAccessDate
    self.contentModificationDate = contentModificationDate
    self.attributeModificationDate = attributeModificationDate
    self.linkCount = linkCount
    self.parentDirectory = parentDirectory
    self.volume = volume
    self.typeIdentifier = typeIdentifier
    self.localizedTypeDescription = localizedTypeDescription
    self.labelNumber = labelNumber
    self.localizedLabel = localizedLabel
    self.fileResourceIdentifier = fileResourceIdentifier
    self.volumeIdentifier = volumeIdentifier
    self.fileIdentifier = fileIdentifier
    self.fileContentIdentifier = fileContentIdentifier
    self.preferredIOBlockSize = preferredIOBlockSize
    self.isReadable = isReadable
    self.isWritable = isWritable
    self.isExecutable = isExecutable
    self.fileSecurity = fileSecurity
    self.isExcludedFromBackup = isExcludedFromBackup
    self.tagNames = tagNames
    self.path = path
    self.canonicalPath = canonicalPath
    self.isMountTrigger = isMountTrigger
    self.generationIdentifier = generationIdentifier
    self.documentIdentifier = documentIdentifier
    self.addedToDirectoryDate = addedToDirectoryDate
    self.quarantineProperties = quarantineProperties
    self.mayHaveExtendedAttributes = mayHaveExtendedAttributes
    self.isPurgeable = isPurgeable
    self.isSparse = isSparse
    self.mayShareFileContent = mayShareFileContent
    self.fileResourceType = fileResourceType
    self.directoryEntryCount = directoryEntryCount
    self.volumeLocalizedFormatDescription = volumeLocalizedFormatDescription
    self.volumeTotalCapacity = volumeTotalCapacity
    self.volumeAvailableCapacity = volumeAvailableCapacity
    self.volumeAvailableCapacityForImportantUsage = volumeAvailableCapacityForImportantUsage
    self.volumeAvailableCapacityForOpportunisticUsage = volumeAvailableCapacityForOpportunisticUsage
    self.volumeResourceCount = volumeResourceCount
    self.volumeSupportsPersistentIDs = volumeSupportsPersistentIDs
    self.volumeSupportsSymbolicLinks = volumeSupportsSymbolicLinks
    self.volumeSupportsHardLinks = volumeSupportsHardLinks
    self.volumeSupportsJournaling = volumeSupportsJournaling
    self.volumeIsJournaling = volumeIsJournaling
    self.volumeSupportsSparseFiles = volumeSupportsSparseFiles
    self.volumeSupportsZeroRuns = volumeSupportsZeroRuns
    self.volumeSupportsCaseSensitiveNames = volumeSupportsCaseSensitiveNames
    self.volumeSupportsCasePreservedNames = volumeSupportsCasePreservedNames
    self.volumeSupportsRootDirectoryDates = volumeSupportsRootDirectoryDates
    self.volumeSupportsVolumeSizes = volumeSupportsVolumeSizes
    self.volumeSupportsRenaming = volumeSupportsRenaming
    self.volumeSupportsAdvisoryFileLocking = volumeSupportsAdvisoryFileLocking
    self.volumeSupportsExtendedSecurity = volumeSupportsExtendedSecurity
    self.volumeIsBrowsable = volumeIsBrowsable
    self.volumeMaximumFileSize = volumeMaximumFileSize
    self.volumeIsEjectable = volumeIsEjectable
    self.volumeIsRemovable = volumeIsRemovable
    self.volumeIsInternal = volumeIsInternal
    self.volumeIsAutomounted = volumeIsAutomounted
    self.volumeIsLocal = volumeIsLocal
    self.volumeIsReadOnly = volumeIsReadOnly
    self.volumeCreationDate = volumeCreationDate
    self.volumeURLForRemounting = volumeURLForRemounting
    self.volumeUUIDString = volumeUUIDString
    self.volumeName = volumeName
    self.volumeLocalizedName = volumeLocalizedName
    self.volumeIsEncrypted = volumeIsEncrypted
    self.volumeIsRootFileSystem = volumeIsRootFileSystem
    self.volumeSupportsCompression = volumeSupportsCompression
    self.volumeSupportsFileCloning = volumeSupportsFileCloning
    self.volumeSupportsSwapRenaming = volumeSupportsSwapRenaming
    self.volumeSupportsExclusiveRenaming = volumeSupportsExclusiveRenaming
    self.volumeSupportsImmutableFiles = volumeSupportsImmutableFiles
    self.volumeSupportsAccessPermissions = volumeSupportsAccessPermissions
    self.volumeTypeName = volumeTypeName
    self.volumeSubtype = volumeSubtype
    self.volumeMountFromLocation = volumeMountFromLocation
    self.isUbiquitousItem = isUbiquitousItem
    self.ubiquitousItemHasUnresolvedConflicts = ubiquitousItemHasUnresolvedConflicts
    self.ubiquitousItemIsDownloading = ubiquitousItemIsDownloading
    self.ubiquitousItemIsUploaded = ubiquitousItemIsUploaded
    self.ubiquitousItemIsUploading = ubiquitousItemIsUploading
    self.ubiquitousItemDownloadingStatus = ubiquitousItemDownloadingStatus
    self.ubiquitousItemDownloadingError = ubiquitousItemDownloadingError
    self.ubiquitousItemUploadingError = ubiquitousItemUploadingError
    self.ubiquitousItemDownloadRequested = ubiquitousItemDownloadRequested
    self.ubiquitousItemContainerDisplayName = ubiquitousItemContainerDisplayName
    self.ubiquitousItemIsExcludedFromSync = ubiquitousItemIsExcludedFromSync
    self.ubiquitousItemIsShared = ubiquitousItemIsShared
    self.ubiquitousSharedItemCurrentUserRole = ubiquitousSharedItemCurrentUserRole
    self.ubiquitousSharedItemCurrentUserPermissions = ubiquitousSharedItemCurrentUserPermissions
    self.ubiquitousSharedItemOwnerNameComponents = ubiquitousSharedItemOwnerNameComponents
    self.ubiquitousSharedItemMostRecentEditorNameComponents = ubiquitousSharedItemMostRecentEditorNameComponents
    self.fileProtection = fileProtection
    self.fileSize = fileSize
    self.fileAllocatedSize = fileAllocatedSize
    self.totalFileSize = totalFileSize
    self.totalFileAllocatedSize = totalFileAllocatedSize
    self.isAliasFile = isAliasFile
  }

  public init(_ resourceValues: URLResourceValues) {
    self.allValues = resourceValues.allValues
    self.name = resourceValues.name
    self.localizedName = resourceValues.localizedName
    self.isRegularFile = resourceValues.isRegularFile
    self.isDirectory = resourceValues.isDirectory
    self.isSymbolicLink = resourceValues.isSymbolicLink
    self.isVolume = resourceValues.isVolume
    self.isPackage = resourceValues.isPackage
    self.isApplication = resourceValues.isApplication
    self.applicationIsScriptable = resourceValues.applicationIsScriptable
    self.isSystemImmutable = resourceValues.isSystemImmutable
    self.isUserImmutable = resourceValues.isUserImmutable
    self.isHidden = resourceValues.isHidden
    self.hasHiddenExtension = resourceValues.hasHiddenExtension
    self.creationDate = resourceValues.creationDate
    self.contentAccessDate = resourceValues.contentAccessDate
    self.contentModificationDate = resourceValues.contentModificationDate
    self.attributeModificationDate = resourceValues.attributeModificationDate
    self.linkCount = resourceValues.linkCount
    self.parentDirectory = resourceValues.parentDirectory
    self.volume = resourceValues.volume
    self.typeIdentifier = resourceValues.typeIdentifier
    self.localizedTypeDescription = resourceValues.localizedTypeDescription
    self.labelNumber = resourceValues.labelNumber
    self.localizedLabel = resourceValues.localizedLabel
    self.fileResourceIdentifier = resourceValues.fileResourceIdentifier
    self.volumeIdentifier = resourceValues.volumeIdentifier
    //    self.fileIdentifier = resourceValues.fileIdentifier
    self.fileContentIdentifier = resourceValues.fileContentIdentifier
    self.preferredIOBlockSize = resourceValues.preferredIOBlockSize
    self.isReadable = resourceValues.isReadable
    self.isWritable = resourceValues.isWritable
    self.isExecutable = resourceValues.isExecutable
    self.fileSecurity = resourceValues.fileSecurity
    self.isExcludedFromBackup = resourceValues.isExcludedFromBackup
    self.tagNames = resourceValues.tagNames
    self.path = resourceValues.path
    self.canonicalPath = resourceValues.canonicalPath
    self.isMountTrigger = resourceValues.isMountTrigger
    self.generationIdentifier = resourceValues.generationIdentifier
    self.documentIdentifier = resourceValues.documentIdentifier
    self.addedToDirectoryDate = resourceValues.addedToDirectoryDate
    self.quarantineProperties = resourceValues.quarantineProperties
    self.mayHaveExtendedAttributes = resourceValues.mayHaveExtendedAttributes
    self.isPurgeable = resourceValues.isPurgeable
    self.isSparse = resourceValues.isSparse
    self.mayShareFileContent = resourceValues.mayShareFileContent
    self.fileResourceType = resourceValues.fileResourceType
    //    self.directoryEntryCount = resourceValues.directoryEntryCount
    self.volumeLocalizedFormatDescription = resourceValues.volumeLocalizedFormatDescription
    self.volumeTotalCapacity = resourceValues.volumeTotalCapacity
    self.volumeAvailableCapacity = resourceValues.volumeAvailableCapacity
    self.volumeAvailableCapacityForImportantUsage = resourceValues.volumeAvailableCapacityForImportantUsage
    self.volumeAvailableCapacityForOpportunisticUsage = resourceValues.volumeAvailableCapacityForOpportunisticUsage
    self.volumeResourceCount = resourceValues.volumeResourceCount
    self.volumeSupportsPersistentIDs = resourceValues.volumeSupportsPersistentIDs
    self.volumeSupportsSymbolicLinks = resourceValues.volumeSupportsSymbolicLinks
    self.volumeSupportsHardLinks = resourceValues.volumeSupportsHardLinks
    self.volumeSupportsJournaling = resourceValues.volumeSupportsJournaling
    self.volumeIsJournaling = resourceValues.volumeIsJournaling
    self.volumeSupportsSparseFiles = resourceValues.volumeSupportsSparseFiles
    self.volumeSupportsZeroRuns = resourceValues.volumeSupportsZeroRuns
    self.volumeSupportsCaseSensitiveNames = resourceValues.volumeSupportsCaseSensitiveNames
    self.volumeSupportsCasePreservedNames = resourceValues.volumeSupportsCasePreservedNames
    self.volumeSupportsRootDirectoryDates = resourceValues.volumeSupportsRootDirectoryDates
    self.volumeSupportsVolumeSizes = resourceValues.volumeSupportsVolumeSizes
    self.volumeSupportsRenaming = resourceValues.volumeSupportsRenaming
    self.volumeSupportsAdvisoryFileLocking = resourceValues.volumeSupportsAdvisoryFileLocking
    self.volumeSupportsExtendedSecurity = resourceValues.volumeSupportsExtendedSecurity
    self.volumeIsBrowsable = resourceValues.volumeIsBrowsable
    self.volumeMaximumFileSize = resourceValues.volumeMaximumFileSize
    self.volumeIsEjectable = resourceValues.volumeIsEjectable
    self.volumeIsRemovable = resourceValues.volumeIsRemovable
    self.volumeIsInternal = resourceValues.volumeIsInternal
    self.volumeIsAutomounted = resourceValues.volumeIsAutomounted
    self.volumeIsLocal = resourceValues.volumeIsLocal
    self.volumeIsReadOnly = resourceValues.volumeIsReadOnly
    self.volumeCreationDate = resourceValues.volumeCreationDate
    self.volumeURLForRemounting = resourceValues.volumeURLForRemounting
    self.volumeUUIDString = resourceValues.volumeUUIDString
    self.volumeName = resourceValues.volumeName
    self.volumeLocalizedName = resourceValues.volumeLocalizedName
    self.volumeIsEncrypted = resourceValues.volumeIsEncrypted
    self.volumeIsRootFileSystem = resourceValues.volumeIsRootFileSystem
    self.volumeSupportsCompression = resourceValues.volumeSupportsCompression
    self.volumeSupportsFileCloning = resourceValues.volumeSupportsFileCloning
    self.volumeSupportsSwapRenaming = resourceValues.volumeSupportsSwapRenaming
    self.volumeSupportsExclusiveRenaming = resourceValues.volumeSupportsExclusiveRenaming
    self.volumeSupportsImmutableFiles = resourceValues.volumeSupportsImmutableFiles
    self.volumeSupportsAccessPermissions = resourceValues.volumeSupportsAccessPermissions
    //    self.volumeTypeName = resourceValues.volumeTypeName
    //    self.volumeSubtype = resourceValues.volumeSubtype
    //    self.volumeMountFromLocation = resourceValues.volumeMountFromLocation
    self.isUbiquitousItem = resourceValues.isUbiquitousItem
    self.ubiquitousItemHasUnresolvedConflicts = resourceValues.ubiquitousItemHasUnresolvedConflicts
    self.ubiquitousItemIsDownloading = resourceValues.ubiquitousItemIsDownloading
    self.ubiquitousItemIsUploaded = resourceValues.ubiquitousItemIsUploaded
    self.ubiquitousItemIsUploading = resourceValues.ubiquitousItemIsUploading
    self.ubiquitousItemDownloadingStatus = resourceValues.ubiquitousItemDownloadingStatus
    self.ubiquitousItemDownloadingError = resourceValues.ubiquitousItemDownloadingError
    self.ubiquitousItemUploadingError = resourceValues.ubiquitousItemUploadingError
    self.ubiquitousItemDownloadRequested = resourceValues.ubiquitousItemDownloadRequested
    self.ubiquitousItemContainerDisplayName = resourceValues.ubiquitousItemContainerDisplayName
    self.ubiquitousItemIsExcludedFromSync = resourceValues.ubiquitousItemIsExcludedFromSync
    self.ubiquitousItemIsShared = resourceValues.ubiquitousItemIsShared
    self.ubiquitousSharedItemCurrentUserRole = resourceValues.ubiquitousSharedItemCurrentUserRole
    self.ubiquitousSharedItemCurrentUserPermissions = resourceValues.ubiquitousSharedItemCurrentUserPermissions
    self.ubiquitousSharedItemOwnerNameComponents = resourceValues.ubiquitousSharedItemOwnerNameComponents
    self.ubiquitousSharedItemMostRecentEditorNameComponents = resourceValues.ubiquitousSharedItemMostRecentEditorNameComponents
    self.fileProtection = resourceValues.fileProtection
    self.fileSize = resourceValues.fileSize
    self.fileAllocatedSize = resourceValues.fileAllocatedSize
    self.totalFileSize = resourceValues.totalFileSize
    self.totalFileAllocatedSize = resourceValues.totalFileAllocatedSize
    self.isAliasFile = resourceValues.isAliasFile
  }
}
