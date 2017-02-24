import Foundation

class BattleMode: ApplicationMode{
    func initiliazeChange(context:ApplicationData){
        context->loadGameMap(context->selectedMapIndex)
        context->soundLibraryMixer->playSong(context->soundLibraryMixer->findSong("game1"), context->musicVolume)
    }
    
    func input(context:ApplicationData){
        var currentX:Int
        var currentY:Int
        let panning = false
        let shiftPressed = false
        var panningDirection = Direction.max
        
        currentX = context->x
        currentY = context->y
        
        context->GameModel->clearGameEvents()
        for(key in context->pressedKeys){
            if(GUIKeyType.upArrow == key){
                panningDirection = Direction.north
                panning = true
            }else if(GUIKeyType.downArrow == key){
                panningDirection = Direction.south
                panning = true
            }else if(GUIKeyType.leftArrow == key){
                panningDirection = Direction.west
                panning = true
            }else if(GUIKeyType.leftShift == key || GUIKeyType.rightShift == key){
                shiftPressed = true
            }
            
        }
        
        
        
    }
    
}
