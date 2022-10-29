export interface Response {
  path: string;
  uri: string;
  filename: string;
  filesize: string;
  width: number;
  height: number;
}

export interface ImageMeta {}

export interface OutputOption {
  format: "JPEG" | "PNG";
  quality: number;
  path?: string;
}

export interface Point {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}

export interface Coordnates {
  topLeft: Point;
  topRight: Point;
  bottomLeft: Point;
  bottomRight: Point;
}

export type OrientDegrees = 90 | 180 | 270;

export interface ScaleCSBParam {
  contrast: number; // -100 ~ 100, default: 0
  saturation: number; // -100 ~ 100, default: 0
  brightness: number; // -100 ~ 100, default: 0
}

export interface CornerRadiusParam {
  radius: number;
}

export interface OrientRotateParam {
  degrees: OrientDegrees;
}

export interface ResizeParam {
  width: number;
  height: number;
}
export interface ScaleParam {
  scale: number;
}

export interface ProxyParam {
  cmd: "cropPerspective" | "cropRoundedCorner" | "scaleCSB" | "transOrientRotate" | "transResize" | "transScale";
  param: unknown;
}

// image processing functions
export function cropPerspective(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: Coordnates
): Promise<Response>;
export function cropRoundedCorner(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: CornerRadiusParam
): Promise<Response>;

export function scaleCSB(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: ScaleCSBParam
): Promise<Response>;

export function transOrientRotate(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: OrientRotateParam
): Promise<Response>;
export function transResize(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: ResizeParam
): Promise<Response>;
export function transScale(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: ScaleParam
): Promise<Response>;

export function proxy(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  param: ProxyParam
): Promise<Response>;
export function proxies(
  outOption: OutputOption | null | undefined,
  imgSrcUri: string,
  proxyParams: Array<ProxyParam>
): Promise<Response>;

// meta data functions
export function metaReadData(imgSrcUri: string): Promise<ImageMeta>;
export function metaWriteData(
  imgSrcUri: string,
  metaData: ImageMeta
): Promise<void>;
