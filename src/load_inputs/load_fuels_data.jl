@doc raw"""
    load_fuels_data!(setup::Dict, path::AbstractString, inputs::Dict)

Read input parameters from CSVs related to fuel costs and CO$_2$ content of fuels
"""
function load_fuels_data!(setup::Dict, path::AbstractString, inputs::Dict)

    # Fuel related inputs - read in different files depending on if time domain reduction is activated or not
    TDR_directory = joinpath(path, setup["TimeDomainReductionFolder"])
    # if TDR is used, my_dir = TDR_directory, else my_dir = "system"
    my_dir = get_systemfiles_path(setup, TDR_directory, path)

    filename = "Fuels_data.csv"
    fuels_in = load_dataframe(joinpath(my_dir, filename))

    for nonfuel in ("None",)
        ensure_column!(fuels_in, nonfuel, 0.0)
    end

    # Fuel costs & CO2 emissions rate for each fuel type
    fuels = names(fuels_in)[2:end]
    costs = Matrix(fuels_in[2:end, 2:end])
    CO2_content = fuels_in[1, 2:end] # tons CO2/MMBtu
    fuel_costs = Dict{AbstractString, Array{Float64}}()
    fuel_CO2 = Dict{AbstractString, Float64}()

    scale_factor = setup["ParameterScale"] == 1 ? ModelScalingFactor : 1

    for i in 1:length(fuels)
        # fuel cost is in $/MMBTU w/o scaling, $/Billon BTU w/ scaling
        fuel_costs[fuels[i]] = costs[:, i] / scale_factor
        # No need to scale fuel_CO2, fuel_CO2 is ton/MMBTU or kton/Billion BTU 
        fuel_CO2[fuels[i]] = CO2_content[i]
    end

    inputs["fuels"] = fuels
    inputs["fuel_costs"] = fuel_costs
    inputs["fuel_CO2"] = fuel_CO2

    println(filename * " Successfully Read!")

    return fuel_costs, fuel_CO2
end

@doc raw"""
    load_fuels_data_p!(setup::Dict, p::Portfolio, inputs::Dict)

Read input parameters from portfolio related to fuel costs and CO$_2$ content of fuels
"""
function load_fuels_data_p!(setup::Dict, p::Portfolio, inputs::Dict)

    # Fuel related inputs
    fuels_technologies = collect(get_technologies(SupplyTechnology, p))

    # Scale factor
    scale_factor = setup["ParameterScale"] == 1 ? ModelScalingFactor : 1

    # Fuel costs & CO2 emissions rate for each fuel type
    fuels = []
    fuel_costs = Dict()
    fuel_CO2 = Dict()
    for tech in fuels_technologies
        
        #Extract multifuels
        if tech.fuel isa Vector
            for f in tech.fuel
                fuel_data = []
                # skip reading timeseries if fuel profile already stored
                if !haskey(fuel_costs, f)
                    for year in p.internal.ext["years"]
                        for day in p.internal.ext["order_days"]
                            ts = get_time_series(SingleTimeSeries, tech, f, model_year = year, order_day = day, type=f)
                            time_array = values(ts.data) / scale_factor
                            append!(fuel_data, time_array)
                        end
                    end
                    
                    # store information
                    push!(fuels, f)
                    fuel_costs[f] = fuel_data
                    fuel_CO2[f] = d.co2[d.fuel]
                end

            end

        # Extract single fuel data
        else
            if !haskey(fuel_costs, tech.fuel)
                fuel_data = []
                for year in p.internal.ext["years"]
                    for day in p.internal.ext["order_days"]
                        ts = get_time_series(SingleTimeSeries, tech, tech.fuel, model_year = year, order_day = day, type=tech.fuel)
                        time_array = values(ts.data) / scale_factor
                        append!(fuel_data, time_array)
                    end
                end
                # store information
                push!(fuels, tech.fuel)
                fuel_costs[tech.fuel] = fuel_data
                fuel_CO2[tech.fuel] = tech.co2
            end
        end

    end

    # Check for Non column
    if !haskey(fuel_costs, "None")
        costs = zeros(inputs["T"])

        append!(fuels, "None")
        fuel_costs["None"] = costs
        fuel_CO2["None"] = 0.0

    end

    inputs["fuels"] = fuels
    inputs["fuel_costs"] = fuel_costs
    inputs["fuel_CO2"] = fuel_CO2

    println("Fuels data Successfully Read!")

    return
end

function ensure_column!(df::DataFrame, col::AbstractString, fill_element)
    if col ∉ names(df)
        df[!, col] = fill(fill_element, nrow(df))
    end
end
