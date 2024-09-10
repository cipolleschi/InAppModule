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
+      "name": "NativeLocalStorage",
+      "type": "modules",
+      "jsSrcsDir": "specs",
+      "android": {
+         "javaPackageName": "com.nativelocalstorage"
+      }
+   }
}
```
