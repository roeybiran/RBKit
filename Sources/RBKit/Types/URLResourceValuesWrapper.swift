import Foundation
import UniformTypeIdentifiers

public struct URLResourceValuesWrapper {

  // MARK: Lifecycle

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
    isAliasFile: Bool? = nil,
    contentType: UTType? = nil
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
    self.ubiquitousSharedItemMostRecentEditorNameComponents =
      ubiquitousSharedItemMostRecentEditorNameComponents
    self.fileProtection = fileProtection
    self.fileSize = fileSize
    self.fileAllocatedSize = fileAllocatedSize
    self.totalFileSize = totalFileSize
    self.totalFileAllocatedSize = totalFileAllocatedSize
    self.isAliasFile = isAliasFile
    self.contentType = contentType
  }

  public init(_ resourceValues: URLResourceValues) {
    allValues = resourceValues.allValues
    name = resourceValues.name
    localizedName = resourceValues.localizedName
    isRegularFile = resourceValues.isRegularFile
    isDirectory = resourceValues.isDirectory
    isSymbolicLink = resourceValues.isSymbolicLink
    isVolume = resourceValues.isVolume
    isPackage = resourceValues.isPackage
    isApplication = resourceValues.isApplication
    applicationIsScriptable = resourceValues.applicationIsScriptable
    isSystemImmutable = resourceValues.isSystemImmutable
    isUserImmutable = resourceValues.isUserImmutable
    isHidden = resourceValues.isHidden
    hasHiddenExtension = resourceValues.hasHiddenExtension
    creationDate = resourceValues.creationDate
    contentAccessDate = resourceValues.contentAccessDate
    contentModificationDate = resourceValues.contentModificationDate
    attributeModificationDate = resourceValues.attributeModificationDate
    linkCount = resourceValues.linkCount
    parentDirectory = resourceValues.parentDirectory
    volume = resourceValues.volume
    typeIdentifier = resourceValues.typeIdentifier
    localizedTypeDescription = resourceValues.localizedTypeDescription
    labelNumber = resourceValues.labelNumber
    localizedLabel = resourceValues.localizedLabel
    fileResourceIdentifier = resourceValues.fileResourceIdentifier
    volumeIdentifier = resourceValues.volumeIdentifier
    if #available(macOS 13.3, *) {
      fileIdentifier = resourceValues.fileIdentifier
    }
    fileContentIdentifier = resourceValues.fileContentIdentifier
    preferredIOBlockSize = resourceValues.preferredIOBlockSize
    isReadable = resourceValues.isReadable
    isWritable = resourceValues.isWritable
    isExecutable = resourceValues.isExecutable
    fileSecurity = resourceValues.fileSecurity
    isExcludedFromBackup = resourceValues.isExcludedFromBackup
    tagNames = resourceValues.tagNames
    path = resourceValues.path
    canonicalPath = resourceValues.canonicalPath
    isMountTrigger = resourceValues.isMountTrigger
    generationIdentifier = resourceValues.generationIdentifier
    documentIdentifier = resourceValues.documentIdentifier
    addedToDirectoryDate = resourceValues.addedToDirectoryDate
    quarantineProperties = resourceValues.quarantineProperties
    mayHaveExtendedAttributes = resourceValues.mayHaveExtendedAttributes
    isPurgeable = resourceValues.isPurgeable
    isSparse = resourceValues.isSparse
    mayShareFileContent = resourceValues.mayShareFileContent
    fileResourceType = resourceValues.fileResourceType
    if #available(macOS 14.0, *) {
      directoryEntryCount = resourceValues.directoryEntryCount
    }
    volumeLocalizedFormatDescription = resourceValues.volumeLocalizedFormatDescription
    volumeTotalCapacity = resourceValues.volumeTotalCapacity
    volumeAvailableCapacity = resourceValues.volumeAvailableCapacity
    volumeAvailableCapacityForImportantUsage =
      resourceValues.volumeAvailableCapacityForImportantUsage
    volumeAvailableCapacityForOpportunisticUsage =
      resourceValues.volumeAvailableCapacityForOpportunisticUsage
    volumeResourceCount = resourceValues.volumeResourceCount
    volumeSupportsPersistentIDs = resourceValues.volumeSupportsPersistentIDs
    volumeSupportsSymbolicLinks = resourceValues.volumeSupportsSymbolicLinks
    volumeSupportsHardLinks = resourceValues.volumeSupportsHardLinks
    volumeSupportsJournaling = resourceValues.volumeSupportsJournaling
    volumeIsJournaling = resourceValues.volumeIsJournaling
    volumeSupportsSparseFiles = resourceValues.volumeSupportsSparseFiles
    volumeSupportsZeroRuns = resourceValues.volumeSupportsZeroRuns
    volumeSupportsCaseSensitiveNames = resourceValues.volumeSupportsCaseSensitiveNames
    volumeSupportsCasePreservedNames = resourceValues.volumeSupportsCasePreservedNames
    volumeSupportsRootDirectoryDates = resourceValues.volumeSupportsRootDirectoryDates
    volumeSupportsVolumeSizes = resourceValues.volumeSupportsVolumeSizes
    volumeSupportsRenaming = resourceValues.volumeSupportsRenaming
    volumeSupportsAdvisoryFileLocking = resourceValues.volumeSupportsAdvisoryFileLocking
    volumeSupportsExtendedSecurity = resourceValues.volumeSupportsExtendedSecurity
    volumeIsBrowsable = resourceValues.volumeIsBrowsable
    volumeMaximumFileSize = resourceValues.volumeMaximumFileSize
    volumeIsEjectable = resourceValues.volumeIsEjectable
    volumeIsRemovable = resourceValues.volumeIsRemovable
    volumeIsInternal = resourceValues.volumeIsInternal
    volumeIsAutomounted = resourceValues.volumeIsAutomounted
    volumeIsLocal = resourceValues.volumeIsLocal
    volumeIsReadOnly = resourceValues.volumeIsReadOnly
    volumeCreationDate = resourceValues.volumeCreationDate
    volumeURLForRemounting = resourceValues.volumeURLForRemounting
    volumeUUIDString = resourceValues.volumeUUIDString
    volumeName = resourceValues.volumeName
    volumeLocalizedName = resourceValues.volumeLocalizedName
    volumeIsEncrypted = resourceValues.volumeIsEncrypted
    volumeIsRootFileSystem = resourceValues.volumeIsRootFileSystem
    volumeSupportsCompression = resourceValues.volumeSupportsCompression
    volumeSupportsFileCloning = resourceValues.volumeSupportsFileCloning
    volumeSupportsSwapRenaming = resourceValues.volumeSupportsSwapRenaming
    volumeSupportsExclusiveRenaming = resourceValues.volumeSupportsExclusiveRenaming
    volumeSupportsImmutableFiles = resourceValues.volumeSupportsImmutableFiles
    volumeSupportsAccessPermissions = resourceValues.volumeSupportsAccessPermissions
    if #available(macOS 13.3, *) {
      volumeTypeName = resourceValues.volumeTypeName
      volumeSubtype = resourceValues.volumeSubtype
      volumeMountFromLocation = resourceValues.volumeMountFromLocation
    }
    isUbiquitousItem = resourceValues.isUbiquitousItem
    ubiquitousItemHasUnresolvedConflicts = resourceValues.ubiquitousItemHasUnresolvedConflicts
    ubiquitousItemIsDownloading = resourceValues.ubiquitousItemIsDownloading
    ubiquitousItemIsUploaded = resourceValues.ubiquitousItemIsUploaded
    ubiquitousItemIsUploading = resourceValues.ubiquitousItemIsUploading
    ubiquitousItemDownloadingStatus = resourceValues.ubiquitousItemDownloadingStatus
    ubiquitousItemDownloadingError = resourceValues.ubiquitousItemDownloadingError
    ubiquitousItemUploadingError = resourceValues.ubiquitousItemUploadingError
    ubiquitousItemDownloadRequested = resourceValues.ubiquitousItemDownloadRequested
    ubiquitousItemContainerDisplayName = resourceValues.ubiquitousItemContainerDisplayName
    ubiquitousItemIsExcludedFromSync = resourceValues.ubiquitousItemIsExcludedFromSync
    ubiquitousItemIsShared = resourceValues.ubiquitousItemIsShared
    ubiquitousSharedItemCurrentUserRole = resourceValues.ubiquitousSharedItemCurrentUserRole
    ubiquitousSharedItemCurrentUserPermissions = resourceValues.ubiquitousSharedItemCurrentUserPermissions
    ubiquitousSharedItemOwnerNameComponents = resourceValues.ubiquitousSharedItemOwnerNameComponents
    ubiquitousSharedItemMostRecentEditorNameComponents = resourceValues.ubiquitousSharedItemMostRecentEditorNameComponents
    fileProtection = resourceValues.fileProtection
    fileSize = resourceValues.fileSize
    fileAllocatedSize = resourceValues.fileAllocatedSize
    totalFileSize = resourceValues.totalFileSize
    totalFileAllocatedSize = resourceValues.totalFileAllocatedSize
    isAliasFile = resourceValues.isAliasFile
    contentType = resourceValues.contentType
  }

  // MARK: Public

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
  public var contentType: UTType?

}
