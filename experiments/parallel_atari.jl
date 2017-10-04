using ArcadeLearningEnvironment
using CGP
using Logging
using Images

function play_atari(c::Chromosome, game::Game, display::Bool, frame_dir::String)
    reset_game(game.ale)
    reward = 0
    frames = 0
    while ~game_over(game.ale)
        output = process(c, get_inputs(game))
        action = game.actions[indmax(output)]
        for i in 1:4
            reward += act(game.ale, game.actions[indmax(output)])
            frames += 1
            if display
                save(@sprintf("%s/frame_%05d.png", frame_dir, frames), draw(game))
            end
        end
        if frames > 108000
            println("Termination due to frame count")
            break
        end
    end
    reward
end

function play_and_draw(c::Chromosome, game::Game, display::Bool, frame_dir::String)
    mkpath(frame_dir)
    rm(frame_dir, recursive=true)
    mkpath(frame_dir)
    play_atari(c, game, display, frame_dir)
end

function run_ea(seed, jlk)
Logging.configure(filename=log, level=INFO)
Logging.info("I: $seed $ea $ctype")
srand(seed)

game = Game("qbert")
nin = length(get_inputs(game))
nout = length(game.actions)
fit = x->play_atari(x, game, false, frame_dir)
record = x->play_and_draw(x, game, true, frame_dir)
maxfit, best = ea(ctype, nin, nout, fit, true, record)
close!(game)
best



CGP.Config.init("cfg/base.yaml")
if ctype == MTPCGPChromo
    CGP.Config.init("cfg/mtcgp.yaml")
else
    CGP.Config.init("cfg/classic.yaml")
end

Logging.configure(filename=log, level=INFO)
Logging.info("I: $seed $ea $ctype")
srand(seed)

game = Game("qbert")
nin = length(get_inputs(game))
nout = length(game.actions)
fit = x->play_atari(x, game, false, frame_dir)
record = x->play_and_draw(x, game, true, frame_dir)
maxfit, best = ea(ctype, nin, nout, fit, true, record)
close!(game)
best

seed = 0
log = "log"
ea = oneplus
ctype = CGPChromo
frame_dir = "frames"
if length(ARGS) > 0; seed = parse(Int64, ARGS[1]); end
if length(ARGS) > 1; log = ARGS[2]; end
if length(ARGS) > 2; ea = eval(parse(ARGS[3])); end
if length(ARGS) > 3; ctype = eval(parse(ARGS[4])); end
if length(ARGS) > 4; frame_dir = ARGS[5]; end