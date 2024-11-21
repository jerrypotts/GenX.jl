using Revise
using InfrastructureSystems
using PowerSystems
using PowerSystemsInvestmentsPortfolios
using GenX
using TimeSeries
using CSV
using DataFrames
using JLD2
using JSON3
using JSONSchema
using SQLite
using HiGHS
const PSIP=PowerSystemsInvestmentsPortfolios
const IS=InfrastructureSystems

function test_portfolio()

    ###################
    ### Zones ###
    ###################

    z1 = Zone(
        name="MA",
        id=1
    )

    z2 = Zone(
        name="CT",
        id=2
    )

    z3 = Zone(
        name="ME",
        id=3
    )

    ####################
    ##### Thermals #####
    ####################

    t_ma_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_costs=LinearCurve(65400),
        minimum_required_capacity=0.0,
        id=1,
        available=true,
        power_systems_type="ElectricLoad",
        name="MA_natural_gas_combined_cycle",
        ramp_dn_percentage = 0.64,
        ramp_up_percentage = 0.64,
        initial_capacity = 0.0,
        fuel="MA_NG",
        co2 = 0.05306,
        heat_rate_mmbtu_per_mwh = 7.43,
        min_generation_percentage = 0.468,
        balancing_topology="Region",
        region = z1,
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(3.55)), fixed=10287, start_up=91.0, shut_down=0.0),
        maximum_capacity = 10000000,
        cluster = 1,
        start_fuel_mmbtu_per_mw = 2.0,
        start_cost_per_mw = 91.0,
        up_time = 6.0,
        down_time = 6.0,
        reg_max = 0.25,
        rsv_max = 0.5,
        unit_size = 250.0
    )

    t_ct_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_costs=LinearCurve(65400),
        minimum_required_capacity=0.0,
        id=2,
        available=true,
        power_systems_type="ElectricLoad",
        name="CT_natural_gas_combined_cycle",
        ramp_dn_percentage = 0.64,
        ramp_up_percentage = 0.64,
        initial_capacity = 0.0,
        fuel="CT_NG",
        co2 = 0.05306,
        heat_rate_mmbtu_per_mwh = 7.12,
        min_generation_percentage = 0.338,
        balancing_topology="Region",
        region = z2,
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(3.57)), fixed=9698, start_up=91.0, shut_down=0.0),
        maximum_capacity = 10000000,
        start_fuel_mmbtu_per_mw = 2.0,
        start_cost_per_mw = 91.0,
        up_time = 6.0,
        down_time = 6.0,
        reg_max = 0.13333,
        cluster = 1,
        rsv_max = 0.266665,
        unit_size = 250.0

    )

    t_me_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_costs=LinearCurve(65400),
        minimum_required_capacity=0.0,
        id=3,
        available=true,
        power_systems_type="ElectricLoad",
        name="ME_natural_gas_combined_cycle",
        ramp_dn_percentage = 0.64,
        ramp_up_percentage = 0.64,
        initial_capacity = 0.0,
        fuel="ME_NG",
        co2 = 0.05306,
        heat_rate_mmbtu_per_mwh = 12.62,
        min_generation_percentage = 0.474,
        balancing_topology="Region",
        region = z3,
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(4.5)), fixed=16291, start_up=91.0, shut_down=0.0),
        maximum_capacity = 10000000,
        start_fuel_mmbtu_per_mw = 2.0,
        start_cost_per_mw = 91.0,
        up_time = 6.0,
        down_time = 6.0,
        cluster = 1,
        reg_max = 0.033333,
        rsv_max = 0.066667,
        unit_size = 250.0
    )

    #####################
    ##### Renewable #####
    #####################

    t_ma_solar = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.PVe,
        capital_costs=LinearCurve(85300),
        minimum_required_capacity=0.0,
        id=4,
        available=true,
        power_systems_type="ElectricLoad",
        name="MA_solar_pv",
        initial_capacity = 0.0,
        balancing_topology="Region",
        fuel = "None",
        region = z1,
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(0)), fixed=18760, start_up=0.0, shut_down=0.0),
        cluster = 1,
        maximum_capacity = 10000000,
    )


    t_ct_wind = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.WT,
        capital_costs=LinearCurve(97200),
        minimum_required_capacity=0.0,
        id=5,
        available=true,
        power_systems_type="ElectricLoad",
        name="CT_onshore_wind",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = z2,
        fuel = "None",
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(0.1)), fixed=43205, start_up=0.0, shut_down=0.0),
        cluster = 1,
        maximum_capacity = 10000000,
    )

    t_ct_solar = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.PVe,
        capital_costs=LinearCurve(85300),
        minimum_required_capacity=0.0,
        id=6,
        available=true,
        power_systems_type="ElectricLoad",
        name="CT_solar_pv",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = z2,
        fuel = "None",
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(0)), fixed=18760, start_up=0.0, shut_down=0.0),
        cluster = 1,
        maximum_capacity = 10000000,
    )

    t_me_wind = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.WT,
        capital_costs=LinearCurve(97200),
        minimum_required_capacity=0.0,
        id=7,
        available=true,
        name="ME_onshore_wind",
        power_systems_type="ElectricLoad",
        initial_capacity = 0.0,
        balancing_topology="Region",
        fuel = "None",
        region = z3,
        operation_costs = ThermalGenerationCost(variable=CostCurve(LinearCurve(0.1)), fixed=43205, start_up=0.0, shut_down=0.0),
        cluster = 1,
        maximum_capacity = 10000000,
    )

    #####################
    ##### Storage #####
    #####################


    #Discuss with Rodrigo about how to handle the costs
    s_ma_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_costs_power=LinearCurve(19584),
        capital_costs_energy=LinearCurve(22494),
        min_cap_energy=0.0,
        min_cap_power=0.0,
        id=8,
        available=true,
        name="MA_battery",
        storage_tech = StorageTech.LIB,
        existing_cap_power = 0.0,
        existing_cap_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = z1,
        om_costs_power = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=4895, start_up=0.0, shut_down=0.0),
        om_costs_energy = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=5622),
        max_cap_power = 100000000,
        max_cap_energy = 100000000,
        eff_up = 0.92,
        eff_down = 0.92,
        losses = 0.0,
        min_duration = 1.0,
        max_duration = 10.0,
        cluster = 0
    )

    s_ct_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_costs_power=LinearCurve(19584),
        capital_costs_energy=LinearCurve(22494),
        min_cap_energy=0.0,
        min_cap_power=0.0,
        id=9,
        available=true,
        name="CT_battery",
        storage_tech = StorageTech.LIB,
        existing_cap_power = 0.0,
        existing_cap_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = z2,
        om_costs_power = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=4895, start_up=0.0, shut_down=0.0),
        om_costs_energy = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=5622),
        max_cap_power = 1000000000,
        max_cap_energy = 1000000000,
        eff_up = 0.92,
        eff_down = 0.92,
        losses = 0.0,
        min_duration = 1.0,
        max_duration = 10.0,
        cluster = 0

    )

    s_me_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_costs_power=LinearCurve(19584),
        capital_costs_energy=LinearCurve(22494),
        min_cap_energy=0.0,
        min_cap_power=0.0,
        id=10,
        available=true,
        name="ME_battery",
        storage_tech = StorageTech.LIB,
        existing_cap_power = 0.0,
        existing_cap_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = z3,
        om_costs_power = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=4895, start_up=0.0, shut_down=0.0),
        om_costs_energy = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=5622),
        max_cap_power = 10000000,
        max_cap_energy = 10000000,
        eff_up = 0.92,
        eff_down = 0.92,
        losses = 0.0,
        min_duration = 1.0,
        max_duration = 10.0,
        cluster = 0

    )

    ######################
    ######## Lines #######
    ######################

    tx_ma_ct = ACTransportTechnology{ACBranch}(;
        name = "MA_to_CT",
        available=true,
        start_region = z1,
        end_region = z2,
        power_systems_type="ElectricLoad",
        network_id = 1,
        capital_cost = LinearCurve(12060),
        maximum_new_capacity = 2950,
        existing_line_capacity = 0,
        line_loss = 0.012305837,
        base_power = 1.0

    )

    tx_ma_me = ACTransportTechnology{ACBranch}(;
        name = "MA_to_ME",
        available=true,
        start_region = z1,
        end_region = z3,
        power_systems_type="ElectricLoad",
        capital_cost = LinearCurve(19261),
        network_id = 2,
        maximum_new_capacity = 2000,
        existing_line_capacity = 0,
        line_loss = 0.019653847,
        base_power = 1.0
    )
    retire_techs = AggregateRetirementPotential(
        retirement_potential = 0.0
    )
    #=
    retire_techs = RetireableTechnology{ThermalStandard}(
        name = "retires",
        power_systems_type="ElectricLoad",
        can_retire = Dict(Dict(PrimeMovers.BA =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.PVe =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.WT =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.ST =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0)))

    )

    retrofits = RetrofitTechnology{ThermalStandard}(
        name = "retrofits",
        power_systems_type="ElectricLoad",
        can_retrofit = Dict(PrimeMovers.BA =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.PVe =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.WT =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.ST =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0)),
        retrofit_id = Dict(PrimeMovers.BA =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.PVe =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.WT =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.ST =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0)),
        retrofit_efficiency = Dict(PrimeMovers.BA =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.PVe =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.WT =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0),
                            PrimeMovers.ST =>
                            Dict("MA" => 0, "CT" => 0, "ME" => 0)),
    )
    =#
    #####################
    ######## Load #######
    #####################

    demand_ma = DemandRequirement{PowerLoad}(
        name="demand_mw_z1",
        available=true,
        power_systems_type="ElectricLoad",
        region = z1
    )

    demand_ct = DemandRequirement{PowerLoad}(
        name="demand_mw_z2",
        available=true,
        power_systems_type="ElectricLoad",
        region = z2
    )

    demand_me = DemandRequirement{PowerLoad}(
        name="demand_mw_z3",
        available=true,
        power_systems_type="ElectricLoad",
        region = z3
    )

    #####################
    ### DemandSegment ###
    #####################   

    demand_segments = CurtailableDemandSideTechnology{PowerLoad}(
        name = "segments",
        available = true,
        power_systems_type="ElectricLoad",
        voll = 50000.0,
        segments = [1, 2, 3, 4],
        curtailment_cost = [1.0, 0.9, 0.55, 0.2],
        max_demand_curtailment = [1.0, 0.04, 0.024, 0.003],
        #max_demand_curtailment = [0.0, 0.0, 0.0, 0.0],
        curtailment_cost_mwh = [2000.0, 1800.0, 1100.0, 400.0]

    )

    #####################
    #### Carbon Caps ####
    ##################### 

    c1 = CarbonCaps(
        name = "CO_2_Cap_Zone_1",
        available = true,
        power_systems_type = "test",
        eligible_zones = [z1],
        co_2_max_tons_mwh = 0.05,
        co_2_max_mtons = 0.018,
    )
    c2 = CarbonCaps(
        name = "CO_2_Cap_Zone_2",
        power_systems_type = "test",
        available = true,
        eligible_zones = [z2],
        co_2_max_tons_mwh = 0.05,
        co_2_max_mtons = 0.025,
    )
    c3 = CarbonCaps(
        name = "CO_2_Cap_Zone_3",
        power_systems_type = "test",
        available = true,
        eligible_zones = [z3],
        co_2_max_tons_mwh = 0.05,
        co_2_max_mtons = 0.025,
    )

    ##########################
    #### Cap Requirements ####
    ########################## 

    cap1 = MinimumCapacityRequirements(
        name = "min_cap_1",
        power_systems_type = "test",
        available = true,
        eligible_resources = ["MA_solar_pv"],
        min_mw = 5000
    )

    cap2 = MinimumCapacityRequirements(
        name = "min_cap_2",
        power_systems_type = "test",
        available = true,
        eligible_resources = ["CT_onshore_wind"],
        min_mw = 10000
    )

    cap3 = MinimumCapacityRequirements(
        name = "min_cap_3",
        power_systems_type = "test",
        available = true,
        eligible_resources = ["MA_battery", "CT_battery", "ME_battery"],
        min_mw = 6000
    )

    #####################
    ##### Portfolio #####
    #####################

    discount_rate = 0.07
    p_3zone = Portfolio(discount_rate, 0.05, 2025)

    PSIP.add_region!(p_3zone, z1)
    PSIP.add_region!(p_3zone, z2)
    PSIP.add_region!(p_3zone, z3)

    PSIP.add_technology!(p_3zone, t_ma_gas)
    PSIP.add_technology!(p_3zone, t_ct_gas)
    PSIP.add_technology!(p_3zone, t_me_gas)

    PSIP.add_technology!(p_3zone, t_ma_solar)
    PSIP.add_technology!(p_3zone, t_ct_wind)
    PSIP.add_technology!(p_3zone, t_me_wind)
    PSIP.add_technology!(p_3zone, t_ct_solar)

    PSIP.add_technology!(p_3zone, s_ct_battery)
    PSIP.add_technology!(p_3zone, s_ma_battery)
    PSIP.add_technology!(p_3zone, s_me_battery)

    PSIP.add_technology!(p_3zone, tx_ma_ct)
    PSIP.add_technology!(p_3zone, tx_ma_me)

    PSIP.add_technology!(p_3zone, demand_ma)
    PSIP.add_technology!(p_3zone, demand_ct)
    PSIP.add_technology!(p_3zone, demand_me)

    PSIP.add_technology!(p_3zone, demand_segments)
    #PSIP.add_technology!(p_3zone, retire_techs)
    #PSIP.add_technology!(p_3zone, retrofits)

    PSIP.add_requirement!(p_3zone, cap1)
    PSIP.add_requirement!(p_3zone, cap2)
    PSIP.add_requirement!(p_3zone, cap3)

    PSIP.add_requirement!(p_3zone, c1)
    PSIP.add_requirement!(p_3zone, c2)
    PSIP.add_requirement!(p_3zone, c3)

    # Adding demand and timeseries, make artificial days and years since those arent in the inputs
    years = collect(LinRange(2020,2030,11))
    years = Int.(years)
    days = [1,2,3,4,5,6,7]
    daystr = ["01-01", "01-02", "01-03", "01-04", "01-05", "01-06", "01-07"]
    demand_data = DataFrame(CSV.File("C:/Users/jpotts/Documents/genx_dev/1_three_zones/TDR_results/Demand_data.csv"))

    fuel_co2 = Dict("None"=>0, "CT_NG"=>0.05306, "ME_NG"=>0.05306, "MA_NG"=>0.05306)
    fuel_data = DataFrame(CSV.File("C:/Users/jpotts/Documents/genx_dev/1_three_zones/TDR_results/Fuels_data_ts.csv"))
    var = DataFrame(CSV.File("C:/Users/jpotts/Documents/genx_dev/1_three_zones/TDR_results/Generators_variability_ts.csv"))

    resolution = Dates.Hour(1)
    for y in years
        for d in days

            #filter data for investment year
            d_ma = demand_data[(isequal.(demand_data[!,"reference_year"],y)) .& (isequal.(demand_data[!,"reference_day"],d)), "Demand_MW_z1"]
            d_ct = demand_data[(isequal.(demand_data[!,"reference_year"],y)) .& (isequal.(demand_data[!,"reference_day"],d)), "Demand_MW_z2"]
            d_me = demand_data[(isequal.(demand_data[!,"reference_year"],y)) .& (isequal.(demand_data[!,"reference_day"],d)), "Demand_MW_z3"]

            #Make timearrays
            ystr = string(y)
            dstr = daystr[d]   
            dates = range(DateTime("$(ystr)-$(dstr)T00:00:00"), step = resolution, length = 24)
            
            data_demand_ma = TimeArray(dates, d_ma)
            data_demand_ct = TimeArray(dates, d_ct)
            data_demand_me = TimeArray(dates, d_me)

            ts1 = SingleTimeSeries("demand_mw_z1", data_demand_ma)
            ts2 = SingleTimeSeries("demand_mw_z2", data_demand_ct)
            ts3 = SingleTimeSeries("demand_mw_z3", data_demand_me)

            IS.add_time_series!(p_3zone.data, demand_ma, ts1; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, demand_ct, ts2; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, demand_me, ts3; model_year=y, order_day=d)


            f_ma = fuel_data[(isequal.(fuel_data[!,"reference_year"],y)) .& (isequal.(fuel_data[!,"reference_day"],d)), "MA_NG"]
            f_ct = fuel_data[(isequal.(fuel_data[!,"reference_year"],y)) .& (isequal.(fuel_data[!,"reference_day"],d)), "CT_NG"]
            f_me = fuel_data[(isequal.(fuel_data[!,"reference_year"],y)) .& (isequal.(fuel_data[!,"reference_day"],d)), "ME_NG"]
            f_no = fuel_data[(isequal.(fuel_data[!,"reference_year"],y)) .& (isequal.(fuel_data[!,"reference_day"],d)), "None"]

            ts1f = SingleTimeSeries("MA_NG", TimeArray(dates, f_ma))
            ts2f = SingleTimeSeries("CT_NG", TimeArray(dates, f_ct))
            ts3f = SingleTimeSeries("ME_NG", TimeArray(dates, f_me))
            tsnf = SingleTimeSeries("None", TimeArray(dates, f_no))

            IS.add_time_series!(p_3zone.data, t_ma_gas, ts1f; model_year=y, order_day=d, type="MA_NG")
            IS.add_time_series!(p_3zone.data, t_ct_gas, ts2f; model_year=y, order_day=d, type = "CT_NG")
            IS.add_time_series!(p_3zone.data, t_me_gas, ts3f; model_year=y, order_day=d, type = "ME_NG")
            IS.add_time_series!(p_3zone.data, t_ma_solar, tsnf; model_year=y, order_day=d, type = "None")
            IS.add_time_series!(p_3zone.data, t_ct_wind, tsnf; model_year=y, order_day=d, type = "None")
            IS.add_time_series!(p_3zone.data, t_me_wind, tsnf; model_year=y, order_day=d, type = "None")
            IS.add_time_series!(p_3zone.data, t_ct_solar, tsnf; model_year=y, order_day=d, type = "None")


            vmag = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "MA_natural_gas_combined_cycle"]
            vmas = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "MA_solar_pv"]
            vctg = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "CT_natural_gas_combined_cycle"]
            vctw = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "CT_onshore_wind"]
            vcts = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "CT_solar_pv"]
            vmeg = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "ME_natural_gas_combined_cycle"]
            vmew = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "ME_onshore_wind"]
            vmab = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "MA_battery"]
            vctb = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "CT_battery"]
            vmeb = var[(isequal.(var[!,"reference_year"],y)) .& (isequal.(var[!,"reference_day"],d)), "ME_battery"]

            ts_var_ma_gas = SingleTimeSeries("MA_natural_gas_combined_cycle", TimeArray(dates, vmag))
            ts_var_ma_solar = SingleTimeSeries("MA_solar_pv", TimeArray(dates, vmas))
            ts_var_ct_gas = SingleTimeSeries("CT_natural_gas_combined_cycle", TimeArray(dates, vctg))
            ts_var_ct_wind = SingleTimeSeries("CT_onshore_wind", TimeArray(dates, vctw))
            ts_var_ct_solar = SingleTimeSeries("CT_solar_pv", TimeArray(dates, vcts))
            ts_var_me_gas = SingleTimeSeries("ME_natural_gas_combined_cycle", TimeArray(dates, vmeg))
            ts_var_me_wind = SingleTimeSeries("ME_onshore_wind", TimeArray(dates, vmew))
            ts_var_ma_battery = SingleTimeSeries("MA_battery", TimeArray(dates, vmab))
            ts_var_ct_battery = SingleTimeSeries("CT_battery", TimeArray(dates, vctb))
            ts_var_me_battery = SingleTimeSeries("ME_battery", TimeArray(dates, vmeb))

            IS.add_time_series!(p_3zone.data, t_ma_gas, ts_var_ma_gas; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_ct_gas, ts_var_ct_gas; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_me_gas, ts_var_me_gas; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, s_ma_battery, ts_var_ma_battery; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, s_ct_battery, ts_var_ct_battery; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, s_me_battery, ts_var_me_battery; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_me_wind, ts_var_me_wind; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_ct_wind, ts_var_ct_wind; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_ma_solar, ts_var_ma_solar; model_year=y, order_day=d)
            IS.add_time_series!(p_3zone.data, t_ct_solar, ts_var_ct_solar; model_year=y, order_day=d)

        end
    end

    e = Dict()

    e["Regions"] = ["MA", "CT", "ME"]

    # Need portfolio settings, this could go in there
    # 
    # Add different timeseries for each representative period, use attributes to make ordering easier

    e["Rep_Periods"] = 11
    e["Timesteps_per_Rep_Period"] = 168
    e["Sub_Weights"] = [842.3076923,
                        673.8461538,
                        673.8461538,
                        673.8461538,
                        2526.923077,
                        168.4615385,
                        1853.076923,
                        505.3846154,
                        168.4615385,
                        505.3846154,
                        168.4615385,
                    ]
    e["total_timesteps"] = 1848
    e["years"] = Int.(collect(LinRange(2020,2030,11)))
    e["order_days"] = [1,2,3,4,5,6,7]

    e["Minimum_capacity_requirement"] = Dict(1 => 5000, 2 => 10000, 3 => 6000)
    e["resource_capacity_requirement"] = Dict(
        "Min_Cap_1" => ["MA_solar_pv"],
        "Min_Cap_2" => ["CT_onshore_wind"],
        "Min_Cap_3" => ["MA_battery", "ME_battery", "CT_battery"]
    )

    p_3zone.internal.ext = e

    return p_3zone
end

p = test_portfolio()
run_genx_case!(dirname(@__FILE__); portfolio=p)
#run_genx_case!(dirname(@__FILE__))

path = "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones"

settings_path = get_settings_path(path)
genx_settings = get_settings_path(path, "genx_settings.yml") # Settings YAML file path
writeoutput_settings = get_settings_path(path, "output_settings.yml") # Write-output settings YAML file path
mysetup = configure_settings(genx_settings, writeoutput_settings) # mysetup dictionary stores settings and GenX-specific parameters

optimizer = HiGHS.Optimizer
OPTIMIZER = configure_solver(settings_path, optimizer)

# Build model with normal CSV inputs
inputs_csv = load_inputs_csv(mysetup, path)
EP_csv = generate_model(mysetup, inputs_csv, OPTIMIZER)
CSV.write("csv_model.csv", EP_csv.obj_dict)


# Build model with with a PSIP portfolio
inputs_p = load_inputs_portfolio(mysetup, p, path)
#inputs_p["RESOURCES"] = inputs_csv["RESOURCES"]
EP_p = generate_model(mysetup, inputs_p, OPTIMIZER)
CSV.write("portfolio_model.csv", EP_p.obj_dict)

EP, solve_time = solve_model(EP_p, mysetup)

#printing resoursce stuff
keys = [inputs_csv.keys[i] for i in 1:length(inputs_csv.keys) if isassigned(inputs_csv.keys, i)]
for k in keys
    print("\n", k)
end


# Comparing individual load functions
# inputs_p = Dict()
# inputs_csv = Dict()

# #run_genx_case!(dirname(@__FILE__))

# # Network Data
# load_network_data_p!(setup, p, inputs_p)
# load_network_data!(setup, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones\\system", inputs_csv)

# load_demand_data!(setup, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones", inputs_csv)
# load_demand_data_p!(setup, p, inputs_p)


# load_fuels_data!(setup, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones", inputs_csv)
# load_fuels_data_p!(setup, p, inputs_p)


# load_resources_data!(inputs_csv, setup, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones", "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones\\resources")
# load_resources_data_p!(inputs_p, setup, p, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones","C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones\\resources")


# load_generators_variability!(setup, "C:\\Users\\jpotts\\Documents\\genx_dev\\1_three_zones", inputs_csv)
# load_generators_variability_p!(p, inputs_p)

# inputs_csv = load_inputs_csv(setup, path)
# inputs_p = load_inputs_portfolio(setup, p, path)
keys = [inputs_csv.keys[i] for i in 1:length(inputs_csv.keys) if isassigned(inputs_csv.keys, i)]
for k in keys
    #print("\n", k)
    if haskey(inputs_p, k)
        if inputs_csv[k] != inputs_p[k]
            print("\nKey does not match: ", k)
        end
    else 
        print("\nKey not in portfolio inputs: ", k)
    end
end
#=
r_csv = inputs_csv["RESOURCES"][1]
r_p = inputs_p["RESOURCES"][1]
keys = [r_csv.keys[i] for i in 1:length(r_csv.keys) if isassigned(r_csv.keys, i)]
for k in keys
    #print("\n", k)
    #if haskey(inputs_p, k)
        if inputs_csv[k] != inputs_p[k]
            print("\n", k)
        end
    #end
end
=#
#test_dict = Dict(key=>getfield(resources[1], key) for key ∈ propertynames(resources[1]))

#print("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#print(resources)
#print("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

#generate_structs("C:/Users/jpotts/Documents/GitHub/SiennaInvestSchema/SiennaInvestSchema.json", "C:/Users/jpotts/.julia/dev/PowerSystemsInvestmentsPortfolios/src/models/generated")

#r = create_resources_from_portfolio(p, SupplyTechnology{ThermalStandard}) 


#techs = collect(get_technologies(DemandRequirement, p))
#load_data = zeros(1848, 3)
