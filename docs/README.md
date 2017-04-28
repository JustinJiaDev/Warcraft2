# iOS Porting Documentation

Note: The original Linux source code was written by [Professor Nitta](https://github.com/cjnitta) and is not available publicly.

## Completed

| name.h | name.cpp | name.swift | notes |
| --- | --- | --- | --- |
| - | BasicCapabilities.cpp | BasicCapabilities.swift | - |
| - | BuildCapabilities.cpp | BuildCapabilities.swift | - |
| - | BuildingUpgradeCapabilities.cpp | BuildingUpgradeCapabilities.swift | - |
| - | TrainCapabilities.cpp | TrainCapabilities.swift | - |
| - | UnitUpgradeCapabilities.cpp | UnitUpgradeCapabilities.swift | - |
| AIPlayer.h | AIPlayer.cpp | AIPlayer.swift | - |
| ApplicationData.h | ApplicationData.cpp | LaunchViewController.swift | custom iOS native implementation |
| ApplicationMode.h | main.cpp | AppDelegate.swift | custom iOS native implementation |
| AssetDecoratedMap.h | AssetDecoratedMap.cpp | AssetDecoratedMap.swift | - |
| AssetRenderer.h | AssetRenderer.cpp | AssetRenderer.swift | - |
| BattleMode.h | BattleMode.cpp | GameViewController.swift | custom iOS native implementation |
| Bevel.h | Bevel.cpp | Bevel.swift | - |
| DataContainer.h | - | DataContainer.swift | - |
| DataSink.h | - | DataSink.swift | write `Data` instead of raw pointer |
| DataSource.h | - | DataSource.swift | read `Data` instead of raw pointer |
| Debug.h | Debug.cpp | Debug.swift | - |
| FileDataContainer.h | FileDataContainer.cpp | FileDataContainer.swift | - |
| FileDataSink.h | FileDataSink.cpp | FileDataSink.swift | - |
| FileDataSource.h |  FileDataSource.cpp |  FileDataSource.swift | - |
| FogRenderer.h | FogRenderer.cpp | FogRenderer.swift | - |
| GameDataTypes.h | - | GameDataTypes.swift | - |
| GameModel.h | GameModel.cpp | GameModel.swift | - |
| GraphicFactory.h | GraphicFactoryCairo.cpp | GraphicFactory.swift | - |
| GraphicMulticolorTileset.h | GraphicMulticolorTileset.cpp | GraphicMulticolorTileset.swift | - |
| GraphicRecolorMap.h | GraphicRecolorMap.cpp | GraphicRecolorMap.swift | - |
| GraphicResourceContext.h | GraphicFactoryCairo.cpp | GraphicResourceContext.swift | - |
| GraphicSurface.h | GraphicFactoryCairo.cpp | GraphicSurface.swift | - |
| GraphicTileset.h | GraphicTileset.cpp | GraphicTileset.swift | - |
| LineDataSource.h | LineDataSource.cpp | LineDataSource.swift | - |
| MapRenderer.h | MapRenderer.cpp | MapRenderer.swift | - |
| MapSelectionMode.h | MapSelectionMode.cpp | MapViewController.swift | custom iOS native implementation |
| MemoryDataSource.h | MemoryDataSource.cpp | MemoryDataSource.swift | - |
| MiniMapRenderer.h | MiniMapRenderer.cpp | MiniMapRenderer.swift | - |
| PlayerAsset.h | PlayerAsset.cpp | PlayerAsset.swift | - |
| Position.h | Position.cpp | Position.swift | - |
| RandomNumberGenerator.h | - | RandomNumberGenerator.swift | - |
| Rectangle.h | - | Rectangle.swift | `typealias Rectangle = CGRect` |
| ResourceRenderer.h | ResourceRenderer.cpp | ResourceView.swift | custom iOS native implementation |
| RouterMap.h | RouterMap.cpp | RouterMap.swift | - |
| TerrainMap.h | TerrainMap.cpp | TerrainMap.swift | - |
| TextFormatter.h | TextFormatter.cpp | TextFormatter.swift | - |
| Tokenizer.h | Tokenizer.cpp | Tokenizer.swift | - |
| UnitActionRenderer.h | UnitActionRenderer.cpp | UnitActionRenderer.swift | custom iOS native implementation |
| UnitDescriptionRenderer.h | UnitDescriptionRenderer.cpp | StatsView.swift | custom iOS native implementation |
| ViewportRenderer.h | ViewportRenderer.cpp | ViewportRenderer.swift | - |
| VisibilityMap.h | VisibilityMap.cpp | VisibilityMap.swift | - |

### Changes

- Added `throws` to `load()` and file related APIs
- Added custom `GameSound.swift` implementation
- Separated `GraphicSurface` into `ViewSurface`, `GraphicSurface` and `GraphicSurfaceResourceContext` protocols
- Changed graphics APIs to adopt Apple's `SpriteKit` (for `GraphicSurface.swift`), `CoreGraphics` (for `GraphicResourceContext.swift`) and `UIKit` (for `ViewSurface.swift`) frameworks
- Changed `*Mode` to `*ViewController` and diverged from the original implementation
- Changed file APIs to adopt Apple's `Foundation` framework
- Changed UI elements to adopt Apple's `UIKit` framework
- Changed abstract classes (without instance variables) to protocols in `Swift`
- Changed getter methods (without arguments) to computational variables in `Swift`
- Changed variable and method names to follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Dropped the return value of methods which always `return true`

### Future Improvements

- Support multiplayer
- Support `Lua` AI scripts or improve `AIPlayer.swift`
- Support more advanced and custom maps
- Support more asset types
- Support adoptive UI (e.g. use `AutoLayout` if possible)
- Improve `GameSound.swift`
- Improve `MiniMapView.swift` and remove `MiniMapRenderer.swift`
- Change `UnitActionRenderer.swift` to `UICollectionView` subclass and remove `ViewSurface` protocol
- Implement remaining `*Mode`
- Fix random crashes
- "Swiftify" code (e.g. use `Optional` to replace `.none` cases and empty objects if possible)

## Not Ported (View Controllers)

| name.h | name.cpp | name.swift |
| --- | --- | --- |
| ButtonMenuMode.h | ButtonMenuMode.cpp | - |
| EditOptionsMode.h | EditOptionsMode.cpp | - |
| MainMenuMode.h | MainMenuMode.cpp | - |
| MultiPlayerOptionsMenuMode.h | MultiPlayerOptionsMenuMode.cpp | - |
| NetworkOptionsMode.h | NetworkOptionsMode.cpp | - |
| OptionsMenuMode.h | OptionsMenuMode.cpp | - |
| PlayerAIColorSelectMode.h | PlayerAIColorSelectMode.cpp | - |

## Not Going to Implement

| name.h | name.cpp | notes |
| --- | --- | --- |
| ApplicationPath.h | ApplicationPath.cpp | use `Bundle` instead |
| ButtonRenderer.h | ButtonRenderer.cpp | use `UIButton` instead |
| CursorSet.h | CursorSet.cpp | use `UITouch` instead |
| EditRenderer.h | EditRenderer.cpp | adopt `UIKit` classes instead |
| FontTileset.h | FontTileset.cpp | use `UIFont` instead |
| GraphicFactoryCairo.h | GraphicFactoryCairo.cpp | use `GraphicSurface.swift` and `GraphicResourceContext.swift` instead |
| GraphicLoader.h | GraphicLoader.cpp | use `GraphicSurface.swift` and `GraphicResourceContext.swift` instead |
| GUIApplication.h | - | adopt `UIKit` classes instead |
| GUIBox.h | - | adopt `UIKit` classes instead |
| GUIContainer.h | - | adopt `UIKit` classes instead |
| GUICursor.h | - | use `UITouch` instead |
| GUIDisplay.h | - | adopt `UIKit` classes instead |
| GUIDrawingArea.h | - | adopt `UIKit` classes instead |
| GUIEvent.h | - | adopt `UIKit` classes instead |
| GUIFactory.h | - | adopt `UIKit` classes instead |
| GUIFactoryGTK3.h | GUIFactoryGTK3.cpp | adopt `UIKit` classes instead |
| GUIFileChooserDialog.h | - | adopt `UIKit` classes instead |
| GUILabel.h | - | use `UILabel` instead |
| GUIMenu.h | - | adopt `UIKit` classes instead |
| GUIMenuBar.h | - | adopt `UIKit` classes instead |
| GUIMenuItem.h | - | adopt `UIKit` classes instead |
| GUIMenuShell.h | - | adopt `UIKit` classes instead |
| GUIWidget.h | - | adopt `UIKit` classes instead |
| GUIWindow.h | - | adopt `UIKit` classes instead |
| IOChannel.h | - | adopt `Foundation` classes instead |
| IOEvent.h | - | adopt `Foundation` classes instead |
| IOFactory.h | - | adopt `Foundation` classes instead |
| IOFactoryGlib.h | IOFactoryGlib.cpp | adopt `Foundation` classes instead |
| ListViewRenderer.h | ListViewRenderer.cpp | use `UITableView` instead |
| Path.h | Path.cpp | use `URL` instead |
| PeriodicTimeout.h | PeriodicTimeout.cpp | adopt `UIKit` classes instead |
| PixelType.h | PixelType.cpp | use `tilePosition` to handle unit selection instead |
| PlayerCommand.h | - | apply capabilities directly instead |
| SoundClip.h | SoundClip.cpp | use custom `GameSound` implementation instead |
| SoundEventRenderer.h | SoundEventRenderer.cpp | use custom `GameSound` implementation instead |
| SoundLibraryMixer.h | SoundLibraryMixer.cpp | use custom `GameSound` implementation instead |
| SoundOptionsMode.h | SoundOptionsMode.cpp | use custom `GameSound` implementation instead |
