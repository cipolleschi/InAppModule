# In App Turbomodule

This is an example on how to create an In App Turbomodule (not an external library).
To create a Turbomodule in app, we roughly have to:

1. Create the TS specs
2. Configure codegen to run on the app
3. Implement the Native Code
4. Connect The TM with JS

## 1. Create the TS Spec

1. Create a folder called **specs** where we are going to write our Codegen Specs
2. Create a file `NativeLocalStorage.ts` that will contain the spec for our module
3. Add the specs for the `NativeLocalStorage` specs

```ts
import { TurboModule, TurboModuleRegistry } from "react-native";

export interface Spec extends TurboModule {
  setString(value: string, key: string): void;
  getString(key: string): string;
}

export default TurboModuleRegistry.get<Spec>("NativeLocalStorage") as Spec | null;
```

> [!Note]
> The spec file for Turbo Native Modules must have the prefix `Native` to work properly.

## 2. Configure Codegen

1. Open the `package.json` file
2. Add the `codegenConfig` field as it follows

```diff
   "packageManager": "yarn@3.6.4",
+   "codegenConfig": {
+      "name": "NativeLocalStorageSpec",
+      "type": "modules",
+      "jsSrcsDir": "specs",
+      "android": {
+         "javaPackageName": "com.nativelocalstorage"
+      }
+   }
}
```

## 3. Implement the Native Code

### Android:

1. In the folder path `android/app/src/main/java/com`, create a new folder `nativelocalstorage`
2. Create a new file `NativeLocalStorageModule.kt`
3. Modify the `NativeLocalStorageModule.kt` with the following code:
```kt
package com.nativelocalstorage

import android.content.Context
import android.content.SharedPreferences
import com.nativelocalstorage.NativeLocalStorageSpec
import com.facebook.react.bridge.ReactApplicationContext

class NativeLocalStorageModule(reactContext: ReactApplicationContext) : NativeLocalStorageSpec(reactContext) {

  override fun getName() = NAME

  override fun setString(value: String, key: String) {
    val sharedPref = getReactApplicationContext().getSharedPreferences("my_prefs", Context.MODE_PRIVATE)
    val editor = sharedPref.edit()
    editor.putString(key, value)
    editor.apply()
  }

  override fun getString(key: String): String {
    val sharedPref = getReactApplicationContext().getSharedPreferences("my_prefs", Context.MODE_PRIVATE)
    val username = sharedPref.getString(key, "")
    return username.toString()
  }

  companion object {
    const val NAME = "NativeLocalStorage"
  }
}
```
4. In the same folder, create a new file `NativeLocalStoragePackage.kt`.
5. Modify the new file with the following code:
```kt
package com.nativelocalstorage;

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class NativeLocalStoragePackage : TurboReactPackage() {

  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? =
    if (name == NativeLocalStorageModule.NAME) {
      NativeLocalStorageModule(reactContext)
    } else {
      null
    }

  override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
    mapOf(
      NativeLocalStorageModule.NAME to ReactModuleInfo(
        NativeLocalStorageModule.NAME,
        NativeLocalStorageModule.NAME,
        false, // canOverrideExistingModule
        false, // needsEagerInit
        false, // isCxxModule
        true // isTurboModule
      )
    )
  }
}
```
6. in the path `android/app/src/main/java/com/inappmodule`, open the `MainApplication.kt` file and adds the following lines:
```diff
package com.inappmodule

import android.app.Application
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.load
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.soloader.SoLoader
+ import com.nativelocalstorage.NativeLocalStoragePackage

class MainApplication : Application(), ReactApplication {

  override val reactNativeHost: ReactNativeHost =
      object : DefaultReactNativeHost(this) {
        override fun getPackages(): List<ReactPackage> =
            PackageList(this).packages.apply {
              // Packages that cannot be autolinked yet can be added manually here, for example:
              // add(MyReactNativePackage())
+              add(NativeLocalStoragePackage())
            }

        override fun getJSMainModuleName(): String = "index"

        override fun getUseDeveloperSupport(): Boolean = BuildConfig.DEBUG

        override val isNewArchEnabled: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
        override val isHermesEnabled: Boolean = BuildConfig.IS_HERMES_ENABLED
      }

  override val reactHost: ReactHost
    get() = getDefaultReactHost(applicationContext, reactNativeHost)

  override fun onCreate() {
    super.onCreate()
    SoLoader.init(this, false)
    if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
      // If you opted-in for the New Architecture, we load the native entry point for this app.
      load()
    }
  }
}
```

### iOS:

1. Run `yarn install` in the root folder of your project.
2. Navigate to the `ios` folder.
3. Run `bundle install`.
4. Run `RCT_NEW_ARCH_ENABLED=1 bundle exec pod install` (starting from 0.76, you can just run `bundle exec pod install`).
5. Run `open <AppName>.xcworkspace` to Open the Xcode Workspace
6. Right click on your App and select `New Group`.
7. Name the new group `NativeLocalStorage`
8. Select the `NativeLocalStorage` folder
9. Right click on the folder and select `New File...`
10. Select `Cocoa Touch Class`
11. Name the class `RCTNativeLocalStorage` (Make sure to select Objective-C as language)
12. Press `next` until you create the file.
13. From Xcode, rename the `RCTNativeLocalStorage.m` to `RCTNativeLocalStorage.mm` (notice the double `m`)
14. Open the `RCTNativeLocalStorage.h` and modify the file as follows:
```diff
#import <Foundation/Foundation.h>
+ #import <NativeLocalStorageSpec/NativeLocalStorageSpec.h>

NS_ASSUME_NONNULL_BEGIN

- @interface RCTNativeLocalStorage : NSObject
+ @interface RCTNativeLocalStorage : NSObject <NativeLocalStorageSpec>

@end

NS_ASSUME_NONNULL_END
```
15. Open the `RCTNativeLocalStorage.mm` and implement the native code as follows:
```diff
#import "RCTNativeLocalStorage.h"

@implementation RCTNativeLocalStorage

+RCT_EXPORT_MODULE(NativeLocalStorage)

+- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
+ return std::make_shared<facebook::react::NativeLocalStorageSpecJSI>(params);
+}

+- (NSString *)getString:(NSString *)key {
+  return [NSUserDefaults.standardUserDefaults stringForKey:key];
+}

+- (void)setString:(NSString *)value key:(NSString *)key {
+  [NSUserDefaults.standardUserDefaults setObject:value forKey:key];
+}

@end
```

## 4. Connect with the JS

1. Run the app on your device.
    * For iOS, you can run from Xcode or you can go to the root of the project and run `yarn ios`
    * For Android, from the root of the project, run `yarn android`
2. Start metro by running `yarn start`
2. Open the `App.tsx` file
3. Replace the content with the following file.
```tsx
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  useColorScheme,
  Text,
  TextInput,
  Button,
} from 'react-native';

import { Colors } from 'react-native/Libraries/NewAppScreen';

import NativeLocalStorage from './specs/NativeLocalStorage';


function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [value, setValue] = React.useState<string | null>(null);

  const [editingValue, setEditingValue] = React.useState<string | null>(null);

  React.useEffect(() => {
    const s = NativeLocalStorage.getString('myKey');
    setValue(s);
  }, [])

  function saveValue() {
    NativeLocalStorage.setString(editingValue || "", 'myKey');
    setValue(editingValue);
  }

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle, {flex: 1}}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />

      <Text style={styles.text}>Current stored value is: {value || "No Value"}</Text>

      <TextInput placeholder={"Enter the text you want to store"} style={styles.textInput} onChangeText={setEditingValue} />

      <Button title="Save" onPress={saveValue} />

    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  text: {
    margin: 10,
    fontSize: 20
  },
  textInput: {
    margin: 10,
    height: 40,
    borderColor: 'black',
    borderWidth: 1,
    paddingLeft: 5,
    paddingRight: 5,
    borderRadius: 5
  }
});

export default App;
```

This is the resulting app

| Android | iOS |
| :--- | ---: |
| ![Android](android.mov) | ![iOS](ios.mov) |
