import UniformTypeIdentifiers
import Testing

@testable import RBKit

@Suite
struct `URLResourceValues Wrapper Tests` {
    @Test
    func `Memberwise init assigns every property`() {
        let allValues: [URLResourceKey: Any] = [.isDirectoryKey: true]
        let fileResourceIdentifier = NSString("id")
        let volumeIdentifier = NSString("vol-id")
        let generationIdentifier = NSString("gen-id")
        let fileSecurity = NSFileSecurity()
        let date = Date()
        let url = URL(fileURLWithPath: "/test")
        let error = NSError(domain: "test", code: 1)
        let nameComponents = PersonNameComponents()
        let contentType = UTType.jpeg

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
            volumeMaximumFileSize: 999_999,
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
            contentType: contentType
        )

        #expect(wrapper.allValues.isEmpty == false)
        #expect(wrapper.name == "name")
        #expect(wrapper.localizedName == "localized name")
        #expect(wrapper.isRegularFile == true)
        #expect(wrapper.isDirectory == true)
        #expect(wrapper.isSymbolicLink == true)
        #expect(wrapper.isVolume == true)
        #expect(wrapper.isPackage == true)
        #expect(wrapper.isApplication == true)
        #expect(wrapper.applicationIsScriptable == true)
        #expect(wrapper.isSystemImmutable == true)
        #expect(wrapper.isUserImmutable == true)
        #expect(wrapper.isHidden == true)
        #expect(wrapper.hasHiddenExtension == true)
        #expect(wrapper.creationDate == date)
        #expect(wrapper.contentAccessDate == date)
        #expect(wrapper.contentModificationDate == date)
        #expect(wrapper.attributeModificationDate == date)
        #expect(wrapper.linkCount == 1)
        #expect(wrapper.parentDirectory == url)
        #expect(wrapper.volume == url)
        #expect(wrapper.typeIdentifier == "type")
        #expect(wrapper.localizedTypeDescription == "type desc")
        #expect(wrapper.labelNumber == 1)
        #expect(wrapper.localizedLabel == "label")
        #expect(wrapper.fileResourceIdentifier as? NSString == fileResourceIdentifier)
        #expect(wrapper.volumeIdentifier as? NSString == volumeIdentifier)
        #expect(wrapper.fileIdentifier == 123)
        #expect(wrapper.fileContentIdentifier == 456)
        #expect(wrapper.preferredIOBlockSize == 4096)
        #expect(wrapper.isReadable == true)
        #expect(wrapper.isWritable == true)
        #expect(wrapper.isExecutable == true)
        #expect(wrapper.fileSecurity == fileSecurity)
        #expect(wrapper.isExcludedFromBackup == true)
        #expect(wrapper.tagNames == ["tag1"])
        #expect(wrapper.path == "/path")
        #expect(wrapper.canonicalPath == "/canonical")
        #expect(wrapper.isMountTrigger == true)
        #expect(wrapper.generationIdentifier as? NSString == generationIdentifier)
        #expect(wrapper.documentIdentifier == 789)
        #expect(wrapper.addedToDirectoryDate == date)
        #expect(wrapper.quarantineProperties as? [String: String] == ["key": "value"])
        #expect(wrapper.mayHaveExtendedAttributes == true)
        #expect(wrapper.isPurgeable == true)
        #expect(wrapper.isSparse == true)
        #expect(wrapper.mayShareFileContent == true)
        #expect(wrapper.fileResourceType == .regular)
        #expect(wrapper.directoryEntryCount == 5)
        #expect(wrapper.volumeLocalizedFormatDescription == "format")
        #expect(wrapper.volumeTotalCapacity == 1000)
        #expect(wrapper.volumeAvailableCapacity == 500)
        #expect(wrapper.volumeAvailableCapacityForImportantUsage == 400)
        #expect(wrapper.volumeAvailableCapacityForOpportunisticUsage == 300)
        #expect(wrapper.volumeResourceCount == 42)
        #expect(wrapper.volumeSupportsPersistentIDs == true)
        #expect(wrapper.volumeSupportsSymbolicLinks == true)
        #expect(wrapper.volumeSupportsHardLinks == true)
        #expect(wrapper.volumeSupportsJournaling == true)
        #expect(wrapper.volumeIsJournaling == true)
        #expect(wrapper.volumeSupportsSparseFiles == true)
        #expect(wrapper.volumeSupportsZeroRuns == true)
        #expect(wrapper.volumeSupportsCaseSensitiveNames == true)
        #expect(wrapper.volumeSupportsCasePreservedNames == true)
        #expect(wrapper.volumeSupportsRootDirectoryDates == true)
        #expect(wrapper.volumeSupportsVolumeSizes == true)
        #expect(wrapper.volumeSupportsRenaming == true)
        #expect(wrapper.volumeSupportsAdvisoryFileLocking == true)
        #expect(wrapper.volumeSupportsExtendedSecurity == true)
        #expect(wrapper.volumeIsBrowsable == true)
        #expect(wrapper.volumeMaximumFileSize == 999_999)
        #expect(wrapper.volumeIsEjectable == true)
        #expect(wrapper.volumeIsRemovable == true)
        #expect(wrapper.volumeIsInternal == true)
        #expect(wrapper.volumeIsAutomounted == true)
        #expect(wrapper.volumeIsLocal == true)
        #expect(wrapper.volumeIsReadOnly == true)
        #expect(wrapper.volumeCreationDate == date)
        #expect(wrapper.volumeURLForRemounting == url)
        #expect(wrapper.volumeUUIDString == "uuid")
        #expect(wrapper.volumeName == "volume")
        #expect(wrapper.volumeLocalizedName == "loc volume")
        #expect(wrapper.volumeIsEncrypted == true)
        #expect(wrapper.volumeIsRootFileSystem == true)
        #expect(wrapper.volumeSupportsCompression == true)
        #expect(wrapper.volumeSupportsFileCloning == true)
        #expect(wrapper.volumeSupportsSwapRenaming == true)
        #expect(wrapper.volumeSupportsExclusiveRenaming == true)
        #expect(wrapper.volumeSupportsImmutableFiles == true)
        #expect(wrapper.volumeSupportsAccessPermissions == true)
        #expect(wrapper.volumeTypeName == "type")
        #expect(wrapper.volumeSubtype == 1)
        #expect(wrapper.volumeMountFromLocation == "/mount")
        #expect(wrapper.isUbiquitousItem == true)
        #expect(wrapper.ubiquitousItemHasUnresolvedConflicts == true)
        #expect(wrapper.ubiquitousItemIsDownloading == true)
        #expect(wrapper.ubiquitousItemIsUploaded == true)
        #expect(wrapper.ubiquitousItemIsUploading == true)
        #expect(wrapper.ubiquitousItemDownloadingStatus == .current)
        #expect(wrapper.ubiquitousItemDownloadingError as NSError? == error)
        #expect(wrapper.ubiquitousItemUploadingError as NSError? == error)
        #expect(wrapper.ubiquitousItemDownloadRequested == true)
        #expect(wrapper.ubiquitousItemContainerDisplayName == "container")
        #expect(wrapper.ubiquitousItemIsExcludedFromSync == true)
        #expect(wrapper.ubiquitousItemIsShared == true)
        #expect(wrapper.ubiquitousSharedItemCurrentUserRole == .owner)
        #expect(wrapper.ubiquitousSharedItemCurrentUserPermissions == .readOnly)
        #expect(wrapper.ubiquitousSharedItemOwnerNameComponents == nameComponents)
        #expect(wrapper.ubiquitousSharedItemMostRecentEditorNameComponents == nameComponents)
        #expect(wrapper.fileProtection == .complete)
        #expect(wrapper.fileSize == 1024)
        #expect(wrapper.fileAllocatedSize == 2048)
        #expect(wrapper.totalFileSize == 4096)
        #expect(wrapper.totalFileAllocatedSize == 8192)
        #expect(wrapper.isAliasFile == true)
        #expect(wrapper.contentType == contentType)
    }

    @Test
    func `Init from URL resource values surfaces values`() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("test.txt")
        try "test content".write(to: fileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: fileURL) }

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

        let wrapper = URLResourceValuesWrapper(resourceValues)

        #expect(!wrapper.allValues.isEmpty)
        #expect(wrapper.name != nil)
        #expect(wrapper.localizedName != nil)
        #expect(wrapper.isRegularFile != nil)
        #expect(wrapper.isDirectory != nil)
        #expect(wrapper.isSymbolicLink != nil)
        #expect(wrapper.isVolume != nil)
        #expect(wrapper.isPackage != nil)
        #expect(wrapper.isApplication != nil)
        #expect(wrapper.isSystemImmutable != nil)
        #expect(wrapper.isUserImmutable != nil)
        #expect(wrapper.isHidden != nil)
        #expect(wrapper.hasHiddenExtension != nil)
        #expect(wrapper.creationDate != nil)
        #expect(wrapper.contentAccessDate != nil)
        #expect(wrapper.contentModificationDate != nil)
        #expect(wrapper.attributeModificationDate != nil)
        #expect(wrapper.linkCount != nil)
        #expect(wrapper.parentDirectory != nil)
        #expect(wrapper.volume != nil)
        #expect(wrapper.typeIdentifier != nil)
        #expect(wrapper.localizedTypeDescription != nil)
        #expect(wrapper.labelNumber != nil)
        #expect(wrapper.fileResourceIdentifier != nil)
        #expect(wrapper.volumeIdentifier != nil)
        #expect(wrapper.fileContentIdentifier != nil)
        #expect(wrapper.preferredIOBlockSize != nil)
        #expect(wrapper.isReadable != nil)
        #expect(wrapper.isWritable != nil)
        #expect(wrapper.isExecutable != nil)
        #expect(wrapper.fileSecurity != nil)
        #expect(wrapper.isExcludedFromBackup != nil)
        #expect(wrapper.path != nil)
        #expect(wrapper.canonicalPath != nil)
        #expect(wrapper.isMountTrigger != nil)
        #expect(wrapper.generationIdentifier != nil)
        #expect(wrapper.addedToDirectoryDate != nil)
        #expect(wrapper.mayHaveExtendedAttributes != nil)
        #expect(wrapper.isPurgeable != nil)
        #expect(wrapper.isSparse != nil)
        #expect(wrapper.mayShareFileContent != nil)
        #expect(wrapper.fileResourceType != nil)
        #expect(wrapper.volumeLocalizedFormatDescription != nil)
        #expect(wrapper.volumeTotalCapacity != nil)
        #expect(wrapper.volumeAvailableCapacity != nil)
        #expect(wrapper.volumeAvailableCapacityForImportantUsage != nil)
        #expect(wrapper.volumeAvailableCapacityForOpportunisticUsage != nil)
        #expect(wrapper.volumeResourceCount != nil)
        #expect(wrapper.volumeSupportsPersistentIDs != nil)
        #expect(wrapper.volumeSupportsSymbolicLinks != nil)
        #expect(wrapper.volumeSupportsHardLinks != nil)
        #expect(wrapper.volumeSupportsJournaling != nil)
        #expect(wrapper.volumeIsJournaling != nil)
        #expect(wrapper.volumeSupportsSparseFiles != nil)
        #expect(wrapper.volumeSupportsZeroRuns != nil)
        #expect(wrapper.volumeSupportsCaseSensitiveNames != nil)
        #expect(wrapper.volumeSupportsCasePreservedNames != nil)
        #expect(wrapper.volumeSupportsRootDirectoryDates != nil)
        #expect(wrapper.volumeSupportsVolumeSizes != nil)
        #expect(wrapper.volumeSupportsRenaming != nil)
        #expect(wrapper.volumeSupportsAdvisoryFileLocking != nil)
        #expect(wrapper.volumeSupportsExtendedSecurity != nil)
        #expect(wrapper.volumeIsBrowsable != nil)
        #expect(wrapper.volumeMaximumFileSize != nil)
        #expect(wrapper.volumeIsEjectable != nil)
        #expect(wrapper.volumeIsRemovable != nil)
        #expect(wrapper.volumeIsInternal != nil)
        #expect(wrapper.volumeIsAutomounted != nil)
        #expect(wrapper.volumeIsLocal != nil)
        #expect(wrapper.volumeIsReadOnly != nil)
        #expect(wrapper.volumeCreationDate != nil)
        #expect(wrapper.volumeUUIDString != nil)
        #expect(wrapper.volumeName != nil)
        #expect(wrapper.volumeLocalizedName != nil)
        #expect(wrapper.volumeIsEncrypted != nil)
        #expect(wrapper.volumeIsRootFileSystem != nil)
        #expect(wrapper.volumeSupportsCompression != nil)
        #expect(wrapper.volumeSupportsFileCloning != nil)
        #expect(wrapper.volumeSupportsSwapRenaming != nil)
        #expect(wrapper.volumeSupportsExclusiveRenaming != nil)
        #expect(wrapper.volumeSupportsImmutableFiles != nil)
        #expect(wrapper.volumeSupportsAccessPermissions != nil)
        #expect(wrapper.fileProtection != nil)
        #expect(wrapper.fileSize != nil)
        #expect(wrapper.fileAllocatedSize != nil)
        #expect(wrapper.totalFileSize != nil)
        #expect(wrapper.totalFileAllocatedSize != nil)
        #expect(wrapper.isAliasFile != nil)
        #expect(wrapper.contentType != nil)
    }
}
