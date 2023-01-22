require "functions"

addCombinator("near-enemies", getNearEnemies, nil, 30, 150)
addCombinator("near-enemy-structures", getNearEnemyStructures, nil, 30, 150)

log("Registered combinators; maximum tick rate is " .. maximumTickRate)