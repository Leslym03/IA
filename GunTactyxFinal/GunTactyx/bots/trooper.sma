// Trooper

#include "core"
#include "math"
#include "bots"

/* Trooper es diferente de Rookie ya que todos los bots apuntan 
al principio en la misma dirección. Su estrategia todavía 
consiste en mirar a su alrededor y disparar directamente a 
cada enemigo que ve, pero su poder de fuego es más fuerte 
porque muchos bots disparan en la misma dirección. Además, 
algunos bots buscan el segundo bot enemigo más cercano, para 
disparar a objetivos multipe.
    También usa oídos para escuchar disparos enemigos y 
apuntar a enemigos ocultos. Las granadas se lanzan nuevamente 
horizontalmente para posiblemente explotar en contacto cercano 
con los enemigos. Incluso este bot utiliza la misma estrategia 
para cada objetivo, por lo que no se preocupa por proteger al 
jefe cuando debería ser mejor hacerlo.
*/


fight() {
// algunas constantes para hacer que la fuente sea más legible
  new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
  new const ENEMY_WARRIOR = ITEM_ENEMY|ITEM_WARRIOR
  new const ENEMY_GUN = ITEM_ENEMY|ITEM_GUN
// constante que define la tasa de cambios de dirección
  new const float:CHANGE_DIR_TIME = 20.0
// pequeño ángulo para cambiar de dirección frente a las paredes
  new const float:AVOID_WALL_DIR = 0.31415
// extensión máxima de las rotaciones de cabeza (todos los ángulos están en radianes)
  new float:headDir = 1.047
// necesario para el cambio de dirección de cuenta regresiva
  new float:lastTime = getTime()
//// Todos los mates giran en la misma dirección.
  rotate(3.1415)
//// Espere para estar seguro de que todos completaron la rotación
  wait(2.0)
//// Camine (y espere un poco para asegurarse de caminar para las próximas llamadas)
  walk()
  wait(0.02)


// loop forever
  for(;;) {
    new float:thisTime = getTime()
//// Cambiar la dirección de 90 grados cada 10 segundos
    if(thisTime-lastTime > CHANGE_DIR_TIME) {
      lastTime = thisTime
      new float:randAngle = float(random(3)-1)*1.5758
      rotate(getDirection()+randAngle)
//// Si está de pie, cambie de dirección (tal vez el bot golpeó a otro bot)
    } else if(isStanding()) {
      rotate(getDirection()+1.5708)
      wait(1.0)
      walk()
//// Si el muro está más cerca de 5 m, cambie de dirección
    } else if(sight() < 5.0) {
      rotate(getDirection()+AVOID_WALL_DIR)
    }
//// Si hay algo tocado, levántelo (puede ser un encendido)
    new touched = getTouched()
    if(touched) raise(touched)
//// Busca enemigos
    new item = ENEMY_WARRIOR
    new float:dist = 0.0
    new float:yaw
    new float:pitch
    watch(item,dist,yaw,pitch)
//// Si hay un enemigo ...
    if(item == ENEMY_WARRIOR) {
      if(getID()%2 == 0) {
//// ... e ID es incluso buscar de nuevo otro objetivo ...
        new float:oldDist = dist
        new float:oldYaw = yaw
        new float:oldPitch =pitch
        item = ENEMY_WARRIOR
        watch(item,dist,yaw,pitch)
        if(item == ITEM_NONE) {
          item = ENEMY_WARRIOR
          dist = oldDist
          yaw = oldYaw
          pitch = oldPitch
        }
      }
//// ... luego señale al enemigo ...
      rotate(yaw+getDirection())
      bendTorso(pitch) // inclina el torso hacia el enemigo
      bendHead(-pitch) // hacer que la cabeza mire hacia adelante horizontalmente
      rotateHead(0.0)  // (curvas superiores necesarias para enemigos agachados)
//// .... si caminas, corres ...
      if(isWalking())
        run()
//// .... si el enemigo está a su alcance, lanza una granada ...
      if(getGrenadeLoad() > 0 && dist > 30 && dist < 60) {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          launchGrenade()
//// ... de lo contrario dispara una bala ...
      } else {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          shootBullet()
      }
    }
//// En caso de que no se viera ningún enemigo ...
    if(item != ENEMY_WARRIOR) {
//// ... escucha las armas
      new sound
      dist = hear(item,sound,yaw)
//// Disparo escuchado, correr y rotar
      if(item == ENEMY_GUN) {
        if(isWalking())
          run()
        rotate(yaw+getDirection())
        wait(0.5)
//// Nada se oye, camina y mira a tu alrededor
      } else {
        if(isRunning())
          walk()
        rotateHead(headDir)
        if(getHeadYaw() == headDir)
          headDir = -headDir
      }
    }
  }
}

/* basic soccer code */
soccer() {
  new const float:PI = 3.1415
// pequeño ángulo para cambiar de dirección frente a las paredes
  new const float:AVOID_WALL_DIR =
    (getID()%2 == 0? PI/10.0: -PI/10.0)
// constante que define la tasa de cambios de dirección
  new const float:CHANGE_DIR_TIME = 10.0
// necesario para varias cuentas regresivas
  new float:lastTime = getTime()
// rotar, encontrar objetivo y moverse
  rotate(getDirection()+PI*2.0)
// buscar objetivo
  new float:dist
  new float:yaw
  new item
  do {
    item = ITEM_TARGET
    dist = 0.0
    watch(item,dist,yaw)
  } while(item != ITEM_TARGET)
// señalar al objetivo
  rotate(getDirection()+yaw)
  setKickSpeed(getMaxKickSpeed());
  bendTorso(0.3);
  bendHead(-0.3);
  new float:waitTime = 3-getTime()+lastTime;
  if(waitTime > 0)
    wait(waitTime)
  walk()
  wait(0.1)



// loop forever
  for(;;) {
    new float:thisTime = getTime()
// cambiar la dirección de 90 grados cada 10 segundos
    if(thisTime-lastTime > CHANGE_DIR_TIME) {
      lastTime = thisTime
      rotate(getDirection()+(float(random(2))-0.5)*PI)
// si está parado, cambie de dirección (tal vez el bot golpeó a otro bot)
    } else if(isStanding()) {
      rotate(getDirection()+(float(random(2))-0.5)*PI)
      wait(1.0)
      walk()
// Si el muro está más cerca de 2 m, cambie de dirección
    } else if(sight() < 2.0) {
      rotate(getDirection()+AVOID_WALL_DIR)
    }
// si hay algo tocado, levántelo (puede ser un encendido)
    new touched = getTouched()
    if(touched) raise(touched)
// buscar objetivo
    item = ITEM_TARGET
    dist = 0.0
    watch(item,dist,yaw)
// si hay un objetivo ...
    if(item == ITEM_TARGET) {
// ... apunta al objetivo
      rotate(yaw+getDirection())
// si caminas, corre
      if(isWalking())
        run()
    }
  }
}

strategy(){

  new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
  new const ENEMY_WARRIOR = ITEM_ENEMY|ITEM_WARRIOR
  new const ENEMY_GUN = ITEM_ENEMY|ITEM_GUN
// constante que define la tasa de cambios de dirección
  new const float:CHANGE_DIR_TIME = 20.0
// pequeño ángulo para cambiar de dirección frente a las paredes
  new const float:AVOID_WALL_DIR = 0.31415
// extensión máxima de las rotaciones de cabeza (todos los ángulos están en radianes)
  new float:headDir = 1.047
// necesario para el cambio de dirección de cuenta regresiva
  new float:lastTime = getTime()
//// Todos los mates giran en la misma dirección.
  rotate(3.1415)
//// Espere para estar seguro de que todos completaron la rotación
  wait(2.0)
//// Camine (y espere un poco para asegurarse de caminar para las próximas llamadas)
  walk()
  wait(0.02)


  new float: saludActual = getHealth()
  new float: saludMax = getMaxHealth()
  new float: armaduraMax = getMaxArmor()  
  new const ARMOR_FINAL_BOT = BOT_ARMOR_DROP_MAX

// loop forever
  for(;;) {
    new float:thisTime = getTime()
//Rango de valores para la salud
      if(saludActual>1 && saludActual<saludMax){
        new item = ITEM_ARMOR
        new float:dist
        new float:yaw
        //Casos de salud 
        if(saludActual<15){
          ITEM_ARMOR=80
        }
        if(saludActual>15 && saludActual<30){
          ITEM_ARMOR=60
        }
        if(saludActual>30 && saludActual<50){
          ITEM_ARMOR=50
        }
        if(saludActual>50 && saludActual<90){
          ITEM_ARMOR=30
        }
        if(saludActual>80){
          ITEM_ARMOR=20
        }
        //Busca armadura
        dist=0.0
        watch(item,dist,yaw)
        // Levantar lo encontrado y encenderlo
        new touched = getTouched()
        if(touched) raise(touched)
      }
      else{
        //Si camina entonces corre
        if(isWalking())
        run()
      }
      //Si el bot muere
      if(saludActual = 0){
        new item = BOT_ARMOR_DROP_MAX %10
        drop(abs(item))
      }



//// Cambiar la dirección de 90 grados cada 10 segundos
    if(thisTime-lastTime > CHANGE_DIR_TIME) {
      lastTime = thisTime
      new float:randAngle = float(random(3)-1)*1.5758
      rotate(getDirection()+randAngle)
//// Si está de pie, cambie de dirección (tal vez el bot golpeó a otro bot)
    } else if(isStanding()) {
      rotate(getDirection()+1.5708)
      wait(1.0)
      walk()
//// Si el muro está más cerca de 5 m, cambie de dirección
    } else if(sight() < 5.0) {
      rotate(getDirection()+AVOID_WALL_DIR)
    }
//// Si hay algo tocado, levántelo (puede ser un encendido)
    new touched = getTouched()
    if(touched) raise(touched)
//// Busca enemigos
    new item = ENEMY_WARRIOR
    new float:dist = 0.0
    new float:yaw
    new float:pitch
    watch(item,dist,yaw,pitch)
//// Si hay un enemigo ...
    if(item == ENEMY_WARRIOR) {
      if(getID()%2 == 0) {
//// ... e ID es incluso buscar de nuevo otro objetivo ...
        new float:oldDist = dist
        new float:oldYaw = yaw
        new float:oldPitch =pitch
        item = ENEMY_WARRIOR
        watch(item,dist,yaw,pitch)
        if(item == ITEM_NONE) {
          item = ENEMY_WARRIOR
          dist = oldDist
          yaw = oldYaw
          pitch = oldPitch
        }
      }
//// ... luego señale al enemigo ...
      rotate(yaw+getDirection())
      bendTorso(pitch) // inclina el torso hacia el enemigo
      bendHead(-pitch) // hacer que la cabeza mire hacia adelante horizontalmente
      rotateHead(0.0)  // (curvas superiores necesarias para enemigos agachados)
//// .... si caminas, corres ...
      if(isWalking())
        run()
//// .... si el enemigo está a su alcance, lanza una granada ...
      if(getGrenadeLoad() > 0 && dist > 30 && dist < 60) {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          launchGrenade()
//// ... de lo contrario dispara una bala ...
      } else {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          shootBullet()
      }
    }
//// En caso de que no se viera ningún enemigo ...
    if(item != ENEMY_WARRIOR) {
//// ... escucha las armas
      new sound
      dist = hear(item,sound,yaw)
//// Disparo escuchado, correr y rotar
      if(item == ENEMY_GUN) {
        if(isWalking())
          run()
        rotate(yaw+getDirection())
        wait(0.5)
//// Nada se oye, camina y mira a tu alrededor
      } else {
        if(isRunning())
          walk()
        rotateHead(headDir)
        if(getHeadYaw() == headDir)
          headDir = -headDir
      }
    }
  }

}



/* main entry */
main() {
  switch(getPlay()) {
    case PLAY_FIGHT: fight()
    case PLAY_SOCCER: soccer()
    case PLAY_RACE: strategy()
  }
}

