import UniformTypeIdentifiers
import XCTest
@testable import RBKit

final class URLResourceValuesWrapperTests: XCTestCase {
  func testMemberwiseInitAssignsAllProperties() {
    // Given
    let allValues: [URLResourceKey: Any] = [.isDirectoryKey: true]
    let fileResourceIdentifier = NSString("id") // Conforms to NSCopying & NSSecureCoding & NSObjectProtocol
    let volumeIdentifier = NSString("vol-id")
    let generationIdentifier = NSString("gen-id")
    let fileSecurity = NSFileSecurity()
    let date = Date()
    let url = URL(fileURLWithPath: "/test")
    let error = NSError(domain: "test", code: 1)
    let nameComponents = PersonNameComponents()
    let contentType = UTType.jpeg

    // When
    let wrapper = URLResourceValuesWrapper(
      allValues: allValues,
      name: "name",
      localizedName: "localized name",
      isRegularFile: true,
      isDirectory: true,
      isSymbolicLink: true,
      isVolume: true,
      isPackage: true,
      isApplication: true,
      applicationIsScriptable: true,
      isSystemImmutable: true,
      isUserImmutable: true,
      isHidden: true,
      hasHiddenExtension: true,
      creationDate: date,
      contentAccessDate: date,
      contentModificationDate: date,
      attributeModificationDate: date,
      linkCount: 1,
      parentDirectory: url,
      volume: url,
      typeIdentifier: "type",
      localizedTypeDescription: "type desc",
      labelNumber: 1,
      localizedLabel: "label",
      fileResourceIdentifier: fileResourceIdentifier,
      volumeIdentifier: volumeIdentifier,
      fileIdentifier: 123,
      fileContentIdentifier: 456,
      preferredIOBlockSize: 4096,
      isReadable: true,
      isWritable: true,
      isExecutable: true,
      fileSecurity: fileSecurity,
      isExcludedFromBackup: true,
      tagNames: ["tag1"],
      path: "/path",
      canonicalPath: "/canonical",
      isMountTrigger: true,
      generationIdentifier: generationIdentifier,
      documentIdentifier: 789,
      addedToDirectoryDate: date,
      quarantineProperties: ["key": "value"],
      mayHaveExtendedAttributes: true,
      isPurgeable: true,
      isSparse: true,
      mayShareFileContent: true,
      fileResourceType: .regular,
      directoryEntryCount: 5,
      volumeLocalizedFormatDescription: "format",
      volumeTotalCapacity: 1000,
      volumeAvailableCapacity: 500,
      volumeAvailableCapacityForImportantUsage: 400,
      volumeAvailableCapacityForOpportunisticUsage: 300,
      volumeResourceCount: 42,
      volumeSupportsPersistentIDs: true,
      volumeSupportsSymbolicLinks: true,
      volumeSupportsHardLinks: true,
      volumeSupportsJournaling: true,
      volumeIsJournaling: true,
      volumeSupportsSparseFiles: true,
      volumeSupportsZeroRuns: true,
      volumeSupportsCaseSensitiveNames: true,
      volumeSupportsCasePreservedNames: true,
      volumeSupportsRootDirectoryDates: true,
      volumeSupportsVolumeSizes: true,
      volumeSupportsRenaming: true,
      volumeSupportsAdvisoryFileLocking: true,
      volumeSupportsExtendedSecurity: true,
      volumeIsBrowsable: true,
      volumeMaximumFileSize: 999999,
      volumeIsEjectable: true,
      volumeIsRemovable: true,
      volumeIsInternal: true,
      volumeIsAutomounted: true,
      volumeIsLocal: true,
      volumeIsReadOnly: true,
      volumeCreationDate: date,
      volumeURLForRemounting: url,
      volumeUUIDString: "uuid",
      volumeName: "volume",
      volumeLocalizedName: "loc volume",
      volumeIsEncrypted: true,
      volumeIsRootFileSystem: true,
      volumeSupportsCompression: true,
      volumeSupportsFileCloning: true,
      volumeSupportsSwapRenaming: true,
      volumeSupportsExclusiveRenaming: true,
      volumeSupportsImmutableFiles: true,
      volumeSupportsAccessPermissions: true,
      volumeTypeName: "type",
      volumeSubtype: 1,
      volumeMountFromLocation: "/mount",
      isUbiquitousItem: true,
      ubiquitousItemHasUnresolvedConflicts: true,
      ubiquitousItemIsDownloading: true,
      ubiquitousItemIsUploaded: true,
      ubiquitousItemIsUploading: true,
      ubiquitousItemDownloadingStatus: .current,
      ubiquitousItemDownloadingError: error,
      ubiquitousItemUploadingError: error,
      ubiquitousItemDownloadRequested: true,
      ubiquitousItemContainerDisplayName: "container",
      ubiquitousItemIsExcludedFromSync: true,
      ubiquitousItemIsShared: true,
      ubiquitousSharedItemCurrentUserRole: .owner,
      ubiquitousSharedItemCurrentUserPermissions: .readOnly,
      ubiquitousSharedItemOwnerNameComponents: nameComponents,
      ubiquitousSharedItemMostRecentEditorNameComponents: nameComponents,
      fileProtection: .complete,
      fileSize: 1024,
      fileAllocatedSize: 2048,
      totalFileSize: 4096,
      totalFileAllocatedSize: 8192,
      isAliasFile: true,
      contentType: contentType)

    // Then
    XCTAssertFalse(wrapper.allValues.isEmpty)
    XCTAssertEqual(wrapper.name, "name")
    XCTAssertEqual(wrapper.localizedName, "localized name")
    XCTAssertTrue(wrapper.isRegularFile!)
    XCTAssertTrue(wrapper.isDirectory!)
    XCTAssertTrue(wrapper.isSymbolicLink!)
    XCTAssertTrue(wrapper.isVolume!)
    XCTAssertTrue(wrapper.isPackage!)
    XCTAssertTrue(wrapper.isApplication!)
    XCTAssertTrue(wrapper.applicationIsScriptable!)
    XCTAssertTrue(wrapper.isSystemImmutable!)
    XCTAssertTrue(wrapper.isUserImmutable!)
    XCTAssertTrue(wrapper.isHidden!)
    XCTAssertTrue(wrapper.hasHiddenExtension!)
    XCTAssertEqual(wrapper.creationDate, date)
    XCTAssertEqual(wrapper.contentAccessDate, date)
    XCTAssertEqual(wrapper.contentModificationDate, date)
    XCTAssertEqual(wrapper.attributeModificationDate, date)
    XCTAssertEqual(wrapper.linkCount, 1)
    XCTAssertEqual(wrapper.parentDirectory, url)
    XCTAssertEqual(wrapper.volume, url)
    XCTAssertEqual(wrapper.typeIdentifier, "type")
    XCTAssertEqual(wrapper.localizedTypeDescription, "type desc")
    XCTAssertEqual(wrapper.labelNumber, 1)
    XCTAssertEqual(wrapper.localizedLabel, "label")
    XCTAssertEqual(wrapper.fileResourceIdentifier as? NSString, fileResourceIdentifier)
    XCTAssertEqual(wrapper.volumeIdentifier as? NSString, volumeIdentifier)
    XCTAssertEqual(wrapper.fileIdentifier, 123)
    XCTAssertEqual(wrapper.fileContentIdentifier, 456)
    XCTAssertEqual(wrapper.preferredIOBlockSize, 4096)
    XCTAssertTrue(wrapper.isReadable!)
    XCTAssertTrue(wrapper.isWritable!)
    XCTAssertTrue(wrapper.isExecutable!)
    XCTAssertEqual(wrapper.fileSecurity, fileSecurity)
    XCTAssertTrue(wrapper.isExcludedFromBackup!)
    XCTAssertEqual(wrapper.tagNames, ["tag1"])
    XCTAssertEqual(wrapper.path, "/path")
    XCTAssertEqual(wrapper.canonicalPath, "/canonical")
    XCTAssertTrue(wrapper.isMountTrigger!)
    XCTAssertEqual(wrapper.generationIdentifier as? NSString, generationIdentifier)
    XCTAssertEqual(wrapper.documentIdentifier, 789)
    XCTAssertEqual(wrapper.addedToDirectoryDate, date)
    XCTAssertEqual(wrapper.quarantineProperties as? [String: String], ["key": "value"])
    XCTAssertTrue(wrapper.mayHaveExtendedAttributes!)
    XCTAssertTrue(wrapper.isPurgeable!)
    XCTAssertTrue(wrapper.isSparse!)
    XCTAssertTrue(wrapper.mayShareFileContent!)
    XCTAssertEqual(wrapper.fileResourceType, .regular)
    XCTAssertEqual(wrapper.directoryEntryCount, 5)
    XCTAssertEqual(wrapper.volumeLocalizedFormatDescription, "format")
    XCTAssertEqual(wrapper.volumeTotalCapacity, 1000)
    XCTAssertEqual(wrapper.volumeAvailableCapacity, 500)
    XCTAssertEqual(wrapper.volumeAvailableCapacityForImportantUsage, 400)
    XCTAssertEqual(wrapper.volumeAvailableCapacityForOpportunisticUsage, 300)
    XCTAssertEqual(wrapper.volumeResourceCount, 42)
    XCTAssertTrue(wrapper.volumeSupportsPersistentIDs!)
    XCTAssertTrue(wrapper.volumeSupportsSymbolicLinks!)
    XCTAssertTrue(wrapper.volumeSupportsHardLinks!)
    XCTAssertTrue(wrapper.volumeSupportsJournaling!)
    XCTAssertTrue(wrapper.volumeIsJournaling!)
    XCTAssertTrue(wrapper.volumeSupportsSparseFiles!)
    XCTAssertTrue(wrapper.volumeSupportsZeroRuns!)
    XCTAssertTrue(wrapper.volumeSupportsCaseSensitiveNames!)
    XCTAssertTrue(wrapper.volumeSupportsCasePreservedNames!)
    XCTAssertTrue(wrapper.volumeSupportsRootDirectoryDates!)
    XCTAssertTrue(wrapper.volumeSupportsVolumeSizes!)
    XCTAssertTrue(wrapper.volumeSupportsRenaming!)
    XCTAssertTrue(wrapper.volumeSupportsAdvisoryFileLocking!)
    XCTAssertTrue(wrapper.volumeSupportsExtendedSecurity!)
    XCTAssertTrue(wrapper.volumeIsBrowsable!)
    XCTAssertEqual(wrapper.volumeMaximumFileSize, 999999)
    XCTAssertTrue(wrapper.volumeIsEjectable!)
    XCTAssertTrue(wrapper.volumeIsRemovable!)
    XCTAssertTrue(wrapper.volumeIsInternal!)
    XCTAssertTrue(wrapper.volumeIsAutomounted!)
    XCTAssertTrue(wrapper.volumeIsLocal!)
    XCTAssertTrue(wrapper.volumeIsReadOnly!)
    XCTAssertEqual(wrapper.volumeCreationDate, date)
    XCTAssertEqual(wrapper.volumeURLForRemounting, url)
    XCTAssertEqual(wrapper.volumeUUIDString, "uuid")
    XCTAssertEqual(wrapper.volumeName, "volume")
    XCTAssertEqual(wrapper.volumeLocalizedName, "loc volume")
    XCTAssertTrue(wrapper.volumeIsEncrypted!)
    XCTAssertTrue(wrapper.volumeIsRootFileSystem!)
    XCTAssertTrue(wrapper.volumeSupportsCompression!)
    XCTAssertTrue(wrapper.volumeSupportsFileCloning!)
    XCTAssertTrue(wrapper.volumeSupportsSwapRenaming!)
    XCTAssertTrue(wrapper.volumeSupportsExclusiveRenaming!)
    XCTAssertTrue(wrapper.volumeSupportsImmutableFiles!)
    XCTAssertTrue(wrapper.volumeSupportsAccessPermissions!)
    XCTAssertEqual(wrapper.volumeTypeName, "type")
    XCTAssertEqual(wrapper.volumeSubtype, 1)
    XCTAssertEqual(wrapper.volumeMountFromLocation, "/mount")
    XCTAssertTrue(wrapper.isUbiquitousItem!)
    XCTAssertTrue(wrapper.ubiquitousItemHasUnresolvedConflicts!)
    XCTAssertTrue(wrapper.ubiquitousItemIsDownloading!)
    XCTAssertTrue(wrapper.ubiquitousItemIsUploaded!)
    XCTAssertTrue(wrapper.ubiquitousItemIsUploading!)
    XCTAssertEqual(wrapper.ubiquitousItemDownloadingStatus, .current)
    XCTAssertEqual(wrapper.ubiquitousItemDownloadingError, error)
    XCTAssertEqual(wrapper.ubiquitousItemUploadingError, error)
    XCTAssertTrue(wrapper.ubiquitousItemDownloadRequested!)
    XCTAssertEqual(wrapper.ubiquitousItemContainerDisplayName, "container")
    XCTAssertTrue(wrapper.ubiquitousItemIsExcludedFromSync!)
    XCTAssertTrue(wrapper.ubiquitousItemIsShared!)
    XCTAssertEqual(wrapper.ubiquitousSharedItemCurrentUserRole, .owner)
    XCTAssertEqual(wrapper.ubiquitousSharedItemCurrentUserPermissions, .readOnly)
    XCTAssertEqual(wrapper.ubiquitousSharedItemOwnerNameComponents, nameComponents)
    XCTAssertEqual(wrapper.ubiquitousSharedItemMostRecentEditorNameComponents, nameComponents)
    XCTAssertEqual(wrapper.fileProtection, .complete)
    XCTAssertEqual(wrapper.fileSize, 1024)
    XCTAssertEqual(wrapper.fileAllocatedSize, 2048)
    XCTAssertEqual(wrapper.totalFileSize, 4096)
    XCTAssertEqual(wrapper.totalFileAllocatedSize, 8192)
    XCTAssertTrue(wrapper.isAliasFile!)
    XCTAssertEqual(wrapper.contentType, contentType)
  }

  func testActualURLResourceValues() throws {
    // Given
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent("test.txt")
    try "test content".write(to: fileURL, atomically: true, encoding: .utf8)
    defer {
      try? FileManager.default.removeItem(at: fileURL)
    }

    let resourceValues = try fileURL.resourceValues(forKeys: [
      .nameKey,
      .localizedNameKey,
      .isRegularFileKey,
      .isDirectoryKey,
      .isSymbolicLinkKey,
      .isVolumeKey,
      .isPackageKey,
      .isApplicationKey,
      .applicationIsScriptableKey,
      .isSystemImmutableKey,
      .isUserImmutableKey,
      .isHiddenKey,
      .hasHiddenExtensionKey,
      .creationDateKey,
      .contentAccessDateKey,
      .contentModificationDateKey,
      .attributeModificationDateKey,
      .linkCountKey,
      .parentDirectoryURLKey,
      .volumeURLKey,
      .typeIdentifierKey,
      .localizedTypeDescriptionKey,
      .labelNumberKey,
      .labelColorKey,
      .localizedLabelKey,
      .fileResourceIdentifierKey,
      .volumeIdentifierKey,
      .fileContentIdentifierKey,
      .preferredIOBlockSizeKey,
      .isReadableKey,
      .isWritableKey,
      .isExecutableKey,
      .fileSecurityKey,
      .isExcludedFromBackupKey,
      .tagNamesKey,
      .pathKey,
      .canonicalPathKey,
      .isMountTriggerKey,
      .generationIdentifierKey,
      .documentIdentifierKey,
      .addedToDirectoryDateKey,
      .quarantinePropertiesKey,
      .mayHaveExtendedAttributesKey,
      .isPurgeableKey,
      .isSparseKey,
      .mayShareFileContentKey,
      .fileResourceTypeKey,
      .volumeLocalizedFormatDescriptionKey,
      .volumeTotalCapacityKey,
      .volumeAvailableCapacityKey,
      .volumeAvailableCapacityForImportantUsageKey,
      .volumeAvailableCapacityForOpportunisticUsageKey,
      .volumeResourceCountKey,
      .volumeSupportsPersistentIDsKey,
      .volumeSupportsSymbolicLinksKey,
      .volumeSupportsHardLinksKey,
      .volumeSupportsJournalingKey,
      .volumeIsJournalingKey,
      .volumeSupportsSparseFilesKey,
      .volumeSupportsZeroRunsKey,
      .volumeSupportsCaseSensitiveNamesKey,
      .volumeSupportsCasePreservedNamesKey,
      .volumeSupportsRootDirectoryDatesKey,
      .volumeSupportsVolumeSizesKey,
      .volumeSupportsRenamingKey,
      .volumeSupportsAdvisoryFileLockingKey,
      .volumeSupportsExtendedSecurityKey,
      .volumeIsBrowsableKey,
      .volumeMaximumFileSizeKey,
      .volumeIsEjectableKey,
      .volumeIsRemovableKey,
      .volumeIsInternalKey,
      .volumeIsAutomountedKey,
      .volumeIsLocalKey,
      .volumeIsReadOnlyKey,
      .volumeCreationDateKey,
      .volumeURLForRemountingKey,
      .volumeUUIDStringKey,
      .volumeNameKey,
      .volumeLocalizedNameKey,
      .volumeIsEncryptedKey,
      .volumeIsRootFileSystemKey,
      .volumeSupportsCompressionKey,
      .volumeSupportsFileCloningKey,
      .volumeSupportsSwapRenamingKey,
      .volumeSupportsExclusiveRenamingKey,
      .volumeSupportsImmutableFilesKey,
      .volumeSupportsAccessPermissionsKey,
//      .volumeTypeNameKey,
//      .volumeSubtypeKey,
      .isUbiquitousItemKey,
      .ubiquitousItemHasUnresolvedConflictsKey,
      .ubiquitousItemIsDownloadingKey,
      .ubiquitousItemIsUploadedKey,
      .ubiquitousItemIsUploadingKey,
      .ubiquitousItemDownloadingStatusKey,
      .ubiquitousItemDownloadingErrorKey,
      .ubiquitousItemUploadingErrorKey,
      .ubiquitousItemDownloadRequestedKey,
      .ubiquitousItemContainerDisplayNameKey,
      .ubiquitousItemIsExcludedFromSyncKey,
      .ubiquitousItemIsSharedKey,
      .ubiquitousSharedItemCurrentUserRoleKey,
      .ubiquitousSharedItemCurrentUserPermissionsKey,
      .ubiquitousSharedItemOwnerNameComponentsKey,
      .ubiquitousSharedItemMostRecentEditorNameComponentsKey,
      .fileProtectionKey,
      .fileSizeKey,
      .fileAllocatedSizeKey,
      .totalFileSizeKey,
      .totalFileAllocatedSizeKey,
      .isAliasFileKey,
      .contentTypeKey,
    ])

    // When
    let wrapper = URLResourceValuesWrapper(resourceValues)

    // Then
    XCTAssertNotNil(wrapper.allValues)
    XCTAssertNotNil(wrapper.name)
    XCTAssertNotNil(wrapper.localizedName)
    XCTAssertNotNil(wrapper.isRegularFile)
    XCTAssertNotNil(wrapper.isDirectory)
    XCTAssertNotNil(wrapper.isSymbolicLink)
    XCTAssertNotNil(wrapper.isVolume)
    XCTAssertNotNil(wrapper.isPackage)
    XCTAssertNotNil(wrapper.isApplication)
//    XCTAssertNotNil(wrapper.applicationIsScriptable)
    XCTAssertNotNil(wrapper.isSystemImmutable)
    XCTAssertNotNil(wrapper.isUserImmutable)
    XCTAssertNotNil(wrapper.isHidden)
    XCTAssertNotNil(wrapper.hasHiddenExtension)
    XCTAssertNotNil(wrapper.creationDate)
    XCTAssertNotNil(wrapper.contentAccessDate)
    XCTAssertNotNil(wrapper.contentModificationDate)
    XCTAssertNotNil(wrapper.attributeModificationDate)
    XCTAssertNotNil(wrapper.linkCount)
    XCTAssertNotNil(wrapper.parentDirectory)
    XCTAssertNotNil(wrapper.volume)
    XCTAssertNotNil(wrapper.typeIdentifier)
    XCTAssertNotNil(wrapper.localizedTypeDescription)
    XCTAssertNotNil(wrapper.labelNumber)
//    XCTAssertNotNil(wrapper.localizedLabel)
    XCTAssertNotNil(wrapper.fileResourceIdentifier)
    XCTAssertNotNil(wrapper.volumeIdentifier)
//    XCTAssertNotNil(wrapper.fileIdentifier)
    XCTAssertNotNil(wrapper.fileContentIdentifier)
    XCTAssertNotNil(wrapper.preferredIOBlockSize)
    XCTAssertNotNil(wrapper.isReadable)
    XCTAssertNotNil(wrapper.isWritable)
    XCTAssertNotNil(wrapper.isExecutable)
    XCTAssertNotNil(wrapper.fileSecurity)
    XCTAssertNotNil(wrapper.isExcludedFromBackup)
//    XCTAssertNotNil(wrapper.tagNames)
    XCTAssertNotNil(wrapper.path)
    XCTAssertNotNil(wrapper.canonicalPath)
    XCTAssertNotNil(wrapper.isMountTrigger)
    XCTAssertNotNil(wrapper.generationIdentifier)
//    XCTAssertNotNil(wrapper.documentIdentifier)
    XCTAssertNotNil(wrapper.addedToDirectoryDate)
//    XCTAssertNotNil(wrapper.quarantineProperties)
    XCTAssertNotNil(wrapper.mayHaveExtendedAttributes)
    XCTAssertNotNil(wrapper.isPurgeable)
    XCTAssertNotNil(wrapper.isSparse)
    XCTAssertNotNil(wrapper.mayShareFileContent)
    XCTAssertNotNil(wrapper.fileResourceType)
    XCTAssertNotNil(wrapper.volumeLocalizedFormatDescription)
    XCTAssertNotNil(wrapper.volumeTotalCapacity)
    XCTAssertNotNil(wrapper.volumeAvailableCapacity)
    XCTAssertNotNil(wrapper.volumeAvailableCapacityForImportantUsage)
    XCTAssertNotNil(wrapper.volumeAvailableCapacityForOpportunisticUsage)
    XCTAssertNotNil(wrapper.volumeResourceCount)
    XCTAssertNotNil(wrapper.volumeSupportsPersistentIDs)
    XCTAssertNotNil(wrapper.volumeSupportsSymbolicLinks)
    XCTAssertNotNil(wrapper.volumeSupportsHardLinks)
    XCTAssertNotNil(wrapper.volumeSupportsJournaling)
    XCTAssertNotNil(wrapper.volumeIsJournaling)
    XCTAssertNotNil(wrapper.volumeSupportsSparseFiles)
    XCTAssertNotNil(wrapper.volumeSupportsZeroRuns)
    XCTAssertNotNil(wrapper.volumeSupportsCaseSensitiveNames)
    XCTAssertNotNil(wrapper.volumeSupportsCasePreservedNames)
    XCTAssertNotNil(wrapper.volumeSupportsRootDirectoryDates)
    XCTAssertNotNil(wrapper.volumeSupportsVolumeSizes)
    XCTAssertNotNil(wrapper.volumeSupportsRenaming)
    XCTAssertNotNil(wrapper.volumeSupportsAdvisoryFileLocking)
    XCTAssertNotNil(wrapper.volumeSupportsExtendedSecurity)
    XCTAssertNotNil(wrapper.volumeIsBrowsable)
    XCTAssertNotNil(wrapper.volumeMaximumFileSize)
    XCTAssertNotNil(wrapper.volumeIsEjectable)
    XCTAssertNotNil(wrapper.volumeIsRemovable)
    XCTAssertNotNil(wrapper.volumeIsInternal)
    XCTAssertNotNil(wrapper.volumeIsAutomounted)
    XCTAssertNotNil(wrapper.volumeIsLocal)
    XCTAssertNotNil(wrapper.volumeIsReadOnly)
    XCTAssertNotNil(wrapper.volumeCreationDate)
//    XCTAssertNotNil(wrapper.volumeURLForRemounting)
    XCTAssertNotNil(wrapper.volumeUUIDString)
    XCTAssertNotNil(wrapper.volumeName)
    XCTAssertNotNil(wrapper.volumeLocalizedName)
    XCTAssertNotNil(wrapper.volumeIsEncrypted)
    XCTAssertNotNil(wrapper.volumeIsRootFileSystem)
    XCTAssertNotNil(wrapper.volumeSupportsCompression)
    XCTAssertNotNil(wrapper.volumeSupportsFileCloning)
    XCTAssertNotNil(wrapper.volumeSupportsSwapRenaming)
    XCTAssertNotNil(wrapper.volumeSupportsExclusiveRenaming)
    XCTAssertNotNil(wrapper.volumeSupportsImmutableFiles)
    XCTAssertNotNil(wrapper.volumeSupportsAccessPermissions)
//    XCTAssertNotNil(wrapper.volumeTypeName)
//    XCTAssertNotNil(wrapper.volumeSubtype)
//    XCTAssertNotNil(wrapper.isUbiquitousItem)
//    XCTAssertNotNil(wrapper.ubiquitousItemHasUnresolvedConflicts)
//    XCTAssertNotNil(wrapper.ubiquitousItemIsDownloading)
//    XCTAssertNotNil(wrapper.ubiquitousItemIsUploaded)
//    XCTAssertNotNil(wrapper.ubiquitousItemIsUploading)
//    XCTAssertNotNil(wrapper.ubiquitousItemDownloadingStatus)
//    XCTAssertNotNil(wrapper.ubiquitousItemDownloadingError)
//    XCTAssertNotNil(wrapper.ubiquitousItemUploadingError)
//    XCTAssertNotNil(wrapper.ubiquitousItemDownloadRequested)
//    XCTAssertNotNil(wrapper.ubiquitousItemContainerDisplayName)
//    XCTAssertNotNil(wrapper.ubiquitousItemIsExcludedFromSync)
//    XCTAssertNotNil(wrapper.ubiquitousItemIsShared)
//    XCTAssertNotNil(wrapper.ubiquitousSharedItemCurrentUserRole)
//    XCTAssertNotNil(wrapper.ubiquitousSharedItemCurrentUserPermissions)
//    XCTAssertNotNil(wrapper.ubiquitousSharedItemOwnerNameComponents)
//    XCTAssertNotNil(wrapper.ubiquitousSharedItemMostRecentEditorNameComponents)
    XCTAssertNotNil(wrapper.fileProtection)
    XCTAssertNotNil(wrapper.fileSize)
    XCTAssertNotNil(wrapper.fileAllocatedSize)
    XCTAssertNotNil(wrapper.totalFileSize)
    XCTAssertNotNil(wrapper.totalFileAllocatedSize)
    XCTAssertNotNil(wrapper.isAliasFile)
    XCTAssertNotNil(wrapper.contentType)
  }
}
