-- Data layer: playable classes and growth hooks.

GameClasses = {
    warrior = {
        id = "warrior",
        name = "Warrior",
        base_hp = 120,
        base_damage = 20,
        base_speed = 1.0,
        primary = "melee",
        base_defense = 4.00,
        template_stats = {
            agility = 4.00,
            power = 4.00,
            defense = 4.00,
            dodge = 4.00,
            regen = 4.00,
            crit = 4.00,
            atk_speed = 4.00,
            shield_bonus = 4.00,
        },
        growth = {hp = 8, damage = 2, speed = 0.0},
    },
    archer = {
        id = "archer",
        name = "Archer",
        base_hp = 90,
        base_damage = 14,
        base_speed = 1.15,
        primary = "ranged",
        base_defense = 2.50,
        template_stats = {
            agility = 5.50,
            power = 3.75,
            defense = 2.50,
            dodge = 5.00,
            regen = 2.50,
            crit = 3.50,
            atk_speed = 5.50,
            shield_bonus = 2.00,
        },
        growth = {hp = 5, damage = 2, speed = 0.01},
    },
    mage = {
        id = "mage",
        name = "Mage",
        base_hp = 80,
        base_damage = 18,
        base_speed = 1.05,
        primary = "magic",
        base_defense = 2.25,
        template_stats = {
            agility = 2.75,
            power = 5.75,
            defense = 2.25,
            dodge = 2.50,
            regen = 2.25,
            crit = 5.25,
            atk_speed = 2.75,
            shield_bonus = 1.75,
        },
        growth = {hp = 4, damage = 3, speed = 0.0},
    },
}

GameClassOrder = {"warrior", "archer", "mage"}

function getGameClass(classId)
    if not classId then
        return GameClasses.warrior
    end
    return GameClasses[classId] or GameClasses.warrior
end
