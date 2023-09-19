import { ConfigPlugin, XcodeProject } from '@expo/config-plugins';
type InstallerBlockName = 'pre' | 'post';
export type MapboxNavigationPlugProps = {
    RNMBNAVVersionAndroid?: string;
    RNMBNAVVersioniOS?: string;
    RNMBNAVDownloadToken?: string;
    RNMBNAVPublicToken?: string;
    RNMapboxMapsVersion?: string;
    RNMBNAVFontFamily?: string;
    RNMBNAVPrimaryColour?: string;
    RNMBNAVSecondaryColour?: string;
    RNMBNAVPrimaryTextColour?: string;
    RNMBNAVSecondaryTextColour?: string;
    RNMBNAVTextSizeSmall?: number;
    RNMBNAVTextSizeMedium?: number;
    RNMBNAVTextSizeLarge?: number;
    RNMBNAVTextSizeXLarge?: number;
};
export declare function applyCocoaPodsModifications(contents: string, { RNMBNAVVersioniOS, RNMBNAVDownloadToken, RNMBNAVPublicToken, RNMapboxMapsVersion }: MapboxNavigationPlugProps): string;
export declare function addConstantBlock(src: string, RNMBNAVVersion?: string, RNMBNAVDownloadToken?: string, RNMBNAVPublicToken?: string, RNMapboxMapsVersion?: string): string;
export declare function addDisableOutputPathsBlock(src: string): string;
export declare function addInstallerBlock(src: string, blockName: InstallerBlockName): string;
export declare function addMapboxInstallerBlock(src: string, blockName: InstallerBlockName): string;
/**
 * Exclude building for arm64 on simulator devices in the pbxproj project.
 * Without this, production builds targeting simulators will fail.
 */
export declare function setExcludedArchitectures(project: XcodeProject): XcodeProject;
declare const _default: ConfigPlugin<MapboxNavigationPlugProps>;
export default _default;
