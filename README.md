# Camera_Camera

  

That is plugin contains native access camera your device, Android and iOS. You can take a photo or record video. Return file.

  ## Android
  You need add in **AndroidManifest.xml**
```dart
<activity
android:name="com.yalantis.ucrop.UCropActivity"
android:screenOrientation="portrait"
android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```

  You need add in **app/build.gradle**
```dart
minSdkVersion 21
```

  ## IOS
  You need add in **info.plist**
  ```dart
    	<key>NSCameraUsageDescription</key>
      <string>Can I use the camera please?</string>
      <key>NSMicrophoneUsageDescription</key>
      <string>Can I use the mic please?</string>
  ```

## Mode Photo

## Enable Photo

```dart

Camera(
 orientationEnablePhoto: CameraOrientation.landscape,)

Camera(
 orientationEnablePhoto: CameraOrientation.portrait,)

Camera(
 orientationEnablePhoto: CameraOrientation.all,) // isDefault

```

### Mask Camera

You can add widget top stack camera, Container, Images.png.

```dart

Camera(
 imageMask: Widget
)

```

### Screen Mode

```dart

Camera(
 
 mode: CameraMode.normal or CameraMode.fullscreen
)

```

### Mode Focus

You can add Rectangle , Circle or Square Focus

![](https://i.imgur.com/AhPO41p.jpg)
![](https://i.imgur.com/sGqdE3D.jpg)
![](https://i.imgur.com/6wnWAYA.jpg)

  ```dart
Camera(
       mode: CameraMode.normal,
      imageMask: CameraFocus.rectangle(
                color: Colors.black.withOpacity(0.5),
                ),
     )

  ```

You can take a photo and edit.

```dart

yourFunction () async {

File file = await  Navigator.push(context, MaterialPageRoute(builder: (context) => Camera()));

})

```

### Other mode getFile
```dart

Camera(
  onFile: (File file) => file;
)

```
![](https://i.imgur.com/AupuIRm.jpg)

![](https://i.imgur.com/N7tx5SQ.jpg)


  
  

# Mode Video

  

You cand record video and preview.

  

```dart

yourFunction () async {

File file = await  Navigator.push(context, MaterialPageRoute(builder: (context) => Video()));

})

```

  

## Installation

  

Add package in pubspec.yaml

  

```bash

camera_camera: current_version

```

  

## Usage

  

Import this in your page

  

```dart

import  'package:camera_camera/camera_camera.dart';

```

  

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

  

Please make sure to update tests as appropriate.

  

## License

[MIT](https://choosealicense.com/licenses/mit/)