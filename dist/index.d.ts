import * as React from 'react';
import { IMapboxNavigationProps, IMapboxNavigationFreeDriveProps } from './typings';
declare const MapboxNavigation: (props: IMapboxNavigationProps) => JSX.Element;
declare const MapboxNavigationFreeDrive: React.ForwardRefExoticComponent<IMapboxNavigationFreeDriveProps & React.RefAttributes<unknown>>;
export { MapboxNavigation, MapboxNavigationFreeDrive };
