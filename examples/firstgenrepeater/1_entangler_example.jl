include("setup.jl")

using GLMakie # For plotting
GLMakie.activate!()

##
# Demo the entangler on its own
##

sizes = [5, 10, 5]        # Number of qubits in each register
T2 = 10.0                  # T2 dephasing time of all qubits
F = 0.9                    # Fidelity of the raw Bell pairs
entangler_wait_time = 0.1  # How long to wait if all qubits are busy before retry
entangler_busy_time = 1.0  # How long it takes to establish a newly entangled pair

sim, network = simulation_setup(sizes, T2)

noisy_pair = noisy_pair_func(F)
for (;src, dst) in edges(network)
    @process entangler(sim, network, src, dst, noisy_pair, entangler_wait_time, entangler_busy_time)
end

# set up a plot and save a handle to the plot observable
fig = Figure(resolution=(400,400))
_,ax,_,obs = registernetplot_axis(fig[1,1],network)
display(fig)

# record the simulation progress
step_ts = range(0, 4, step=0.1)
record(fig, "firstgenrepeater-02.entangler.mp4", step_ts, framerate=10) do t
    run(sim, t)
    notify(obs)
    ax.title = "t=$(t)"
end
