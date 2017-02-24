import Foundation

class BattleMode: ApplicationMode{
    func initiliazeChange(context:ApplicationData){
        context->loadGameMap(context->selectedMapIndex)
        context->soundLibraryMixer->playSong(context->soundLibraryMixer->findSong("game1"), context->musicVolume)
    }
}
