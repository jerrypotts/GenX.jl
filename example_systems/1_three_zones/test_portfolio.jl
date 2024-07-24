
function test_portfolio()

    sys = build_system(PSITestSystems, "c_sys5_re")
    set_units_base_system!(sys, "NATURAL_UNITS")


    ###################
    ### Time Series ###
    ###################

    tstamp_2030_ops = collect(
        DateTime("1/1/2030  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2030  23:00:00",
            "d/m/y  H:M:S",
        ),
    )
    tstamp_2035_ops = collect(
        DateTime("1/1/2035  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2035  23:00:00",
            "d/m/y  H:M:S",
        ),
    )

    tstamp_ops = vcat(tstamp_2030_ops, tstamp_2035_ops)
    tstamp_inv = [
        DateTime("1/1/2030  0:00:00", "d/m/y  H:M:S"),
        DateTime("1/1/2035  0:00:00", "d/m/y  H:M:S")
    ]

    ####################
    ##### Thermals #####
    ####################

    t_ma_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_cost=LinearCurve(65400),
        minimum_required_capacity=0.0,
        gen_ID="1",
        available=true,
        name="MA_natural_gas_combined_cycle",
        ramp_down = 0.64,
        ramp_up = 0.64,
        initial_capacity = 0.0,
        fuel=ThermalFuels.NATURAL_GAS,
        cap_size=250.0,
        heat_rate = 7.43,
        minimum_generation = 0.468,
        balancing_topology="Region",
        region = "MA",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(3.55)), fixed=10287, start_up=91.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
        start_fuel = 2.0,
        up_time = 6.0,
        down_time = 6.0,
        reg_max = 0.25,
        rsv_max = 0.5,
    )

    t_ct_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_cost=LinearCurve(65400),
        minimum_required_capacity=0.0,
        gen_ID="2",
        available=true,
        name="CT_natural_gas_combined_cycle",
        ramp_down = 0.64,
        ramp_up = 0.64,
        initial_capacity = 0.0,
        fuel=ThermalFuels.NATURAL_GAS,
        cap_size=250.0,
        heat_rate = 7.12,
        minimum_generation = 0.338,
        balancing_topology="Region",
        region = "CT",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(3.57)), fixed=9698, start_up=91.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
        start_fuel = 2.0,
        up_time = 6.0,
        down_time = 6.0,
        reg_max = 0.13333,
        rsv_max = 0.266665,
    )

    t_me_gas = SupplyTechnology{ThermalStandard}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.ST,
        capital_cost=LinearCurve(65400),
        minimum_required_capacity=0.0,
        gen_ID="3",
        available=true,
        name="ME_natural_gas_combined_cycle",
        ramp_down = 0.64,
        ramp_up = 0.64,
        initial_capacity = 0.0,
        fuel=ThermalFuels.NATURAL_GAS,
        cap_size=250.0,
        heat_rate = 12.62,
        minimum_generation = 0.474,
        balancing_topology="Region",
        region = "ME",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(4.5)), fixed=16291, start_up=91.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
        start_fuel = 2.0,
        up_time = 6.0,
        down_time = 6.0,
        reg_max = 0.033333,
        rsv_max = 0.066667,
    )

    #####################
    ##### Renewable #####
    #####################

    t_ma_solar = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.PVe,
        capital_cost=LinearCurve(85300),
        minimum_required_capacity=0.0,
        gen_ID="4",
        available=true,
        name="MA_solar_pv",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = "MA",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(0)), fixed=18760, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
    )


    t_ct_wind = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.WT,
        capital_cost=LinearCurve(97200),
        minimum_required_capacity=0.0,
        gen_ID="5",
        available=true,
        name="CT_onshore_wind",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = "CT",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(0.1)), fixed=43205, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
    )

    t_ma_solar = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.PVe,
        capital_cost=LinearCurve(85300),
        minimum_required_capacity=0.0,
        gen_ID="6",
        available=true,
        name="CT_solar_pv",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = "CT",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(0)), fixed=18760, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
    )

    t_ct_wind = SupplyTechnology{RenewableDispatch}(;
        base_power=1.0, # Natural Units
        outage_factor = 1.0,
        prime_mover_type=PrimeMovers.WT,
        capital_cost=LinearCurve(97200),
        minimum_required_capacity=0.0,
        gen_ID="7",
        available=true,
        name="ME_onshore_wind",
        initial_capacity = 0.0,
        balancing_topology="Region",
        region = "ME",
        operations_cost = ThermalGenerationCost(variable=CostCurve(LinearCurve(0.1)), fixed=43205, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        cluster = 1,
    )

    #####################
    ##### Storage #####
    #####################


    #Discuss with Rodrigo about how to handle the costs
    s_ma_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_cost_charge=LinearCurve(19584),
        capital_cost_energy=LinearCurve(22494),
        minimum_required_capacity_energy=0.0,
        minimum_required_capacity_charge=0.0,
        gen_ID="8",
        available=true,
        name="MA_battery",
        storage_tech = StorageTech.LIB,
        initial_capacity_charge = 0.0,
        initial_capacity_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = "MA",
        operations_cost = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=16291, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        maximum_capacity_energy = -1,
        cluster = 0,
        efficiency_up = 0.92,
        efficiency_down = 0.92,
        self_discharge = 0.0,
        minimum_duration = 1.0,
        maximum_duration = 10.0,
    )

    s_ct_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_cost_charge=LinearCurve(19584),
        capital_cost_energy=LinearCurve(22494),
        minimum_required_capacity_energy=0.0,
        minimum_required_capacity_charge=0.0,
        gen_ID="8",
        available=true,
        name="CT_battery",
        storage_tech = StorageTech.LIB,
        initial_capacity_charge = 0.0,
        initial_capacity_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = "CT",
        operations_cost = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=16291, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        maximum_capacity_energy = -1,
        cluster = 0,
        efficiency_up = 0.92,
        efficiency_down = 0.92,
        self_discharge = 0.0,
        minimum_duration = 1.0,
        maximum_duration = 10.0,
    )

    s_me_battery = StorageTechnology{Storage}(;
        base_power=1.0, # Natural Units
        prime_mover_type=PrimeMovers.BA,
        capital_cost_charge=LinearCurve(19584),
        capital_cost_energy=LinearCurve(22494),
        minimum_required_capacity_energy=0.0,
        minimum_required_capacity_charge=0.0,
        gen_ID="8",
        available=true,
        name="ME_battery",
        storage_tech = StorageTech.LIB,
        initial_capacity_charge = 0.0,
        initial_capacity_energy = 0.0,
        power_systems_type = "Test",
        balancing_topology="Region",
        region = "ME",
        operations_cost = StorageCost(charge_variable_cost=CostCurve(LinearCurve(0.15)), discharge_variable_cost=CostCurve(LinearCurve(0.15)), fixed=16291, start_up=0.0, shut_down=0.0),
        maximum_capacity = -1,
        maximum_capacity_energy = -1,
        cluster = 0,
        efficiency_up = 0.92,
        efficiency_down = 0.92,
        self_discharge = 0.0,
        minimum_duration = 1.0,
        maximum_duration = 10.0,
    )

    #####################
    ######## Load #######
    #####################

    loads = collect(get_components(PowerLoad, sys));
    peak_load = sum(get_active_power.(loads))

    ts_load_2030 = zeros(length(tstamp_2030_ops))
    ts_load_2035 = zeros(length(tstamp_2030_ops))
    for load in loads
        ts = get_time_series(Deterministic, load, "max_active_power")
        for (date, data) in ts.data
            if date == DateTime("2024-01-01T00:00:00")
                ts_load_2030 += data * get_max_active_power(load)
            else
                ts_load_2035 += data * get_max_active_power(load)
            end
        end
    end
    ts_load_2030 = ts_load_2030 / peak_load
    ts_load_2035 = ts_load_2035 / peak_load

    ts_demand = SingleTimeSeries("ops_peak_load", TimeArray(tstamp_ops, vcat(ts_load_2030, ts_load_2035)), scaling_factor_multiplier = get_peak_load)
    ts_demand_2030 = SingleTimeSeries("ops_peak_load", TimeArray(tstamp_2030_ops, ts_load_2030), scaling_factor_multiplier = get_peak_load)
    ts_demand_2035 = SingleTimeSeries("ops_peak_load", TimeArray(tstamp_2035_ops, ts_load_2035), scaling_factor_multiplier = get_peak_load)

    t_demand = DemandRequirement{PowerLoad}(
        load_growth=0.05,
        name="demand",
        available=true,
        power_systems_type="PowercLoad",
        region="1",
        peak_load=peak_load,
    )

    #####################
    ##### Portfolio #####
    #####################

    discount_rate = 0.07
    p_5bus = Portfolio(discount_rate)

    PSIP.add_technology!(p_5bus, t_th)
    PSIP.add_technology!(p_5bus, t_re)
    PSIP.add_technology!(p_5bus, t_th_exp)
    PSIP.add_technology!(p_5bus, t_demand)

    PSIP.add_time_series!(p_5bus, t_th, ts_th_cheap_inv_capex)
    PSIP.add_time_series!(p_5bus, t_th_exp, ts_th_exp_inv_capex)

    IS.add_time_series!(p_5bus.data, t_re, ts_wind_2030; year = "2030")
    IS.add_time_series!(p_5bus.data, t_re, ts_wind_2035; year = "2035")
    PSIP.add_time_series!(p_5bus, t_re, ts_wind_inv_capex)

    IS.add_time_series!(p_5bus.data, t_demand, ts_demand_2030; year = "2030")
    IS.add_time_series!(p_5bus.data, t_demand, ts_demand_2035; year = "2035")
    IS.get_time_series(
            IS.SingleTimeSeries,
            t_re,
            "ops_variable_cap_factor";
            year = "2035",
        )
end
