-- ========================
-- SCHEMA (dbo)
-- ========================

-- Users
CREATE TABLE dbo.users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(200) NOT NULL,
    email NVARCHAR(255) UNIQUE,
    is_active BIT NOT NULL DEFAULT 1,
    last_login DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- Network types
CREATE TABLE dbo.network_types (
    network_type_id INT IDENTITY(1,1) PRIMARY KEY,
    network_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL
);

-- Operators
CREATE TABLE dbo.operators (
    operator_id INT IDENTITY(1,1) PRIMARY KEY,
    operator_name NVARCHAR(150) NOT NULL,
    operator_code NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- Frequency bands
CREATE TABLE dbo.frequency_bands (
    band_id INT IDENTITY(1,1) PRIMARY KEY,
    band_name NVARCHAR(100) NOT NULL UNIQUE,      -- e.g. "GSM-900", "LTE Band 3"
    rat NVARCHAR(20) NOT NULL,                    -- e.g. "GSM", "LTE"
    frequency_range NVARCHAR(100) NULL,
    uplink_start FLOAT NULL,
    uplink_end FLOAT NULL,
    downlink_start FLOAT NULL,
    downlink_end FLOAT NULL,
    ul_channel INT NULL,
    dl_channel INT NULL,
    description NVARCHAR(500) NULL,
    network_type_id INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_frequency_bands_network_types FOREIGN KEY (network_type_id)
        REFERENCES dbo.network_types(network_type_id)
);

-- Channel tech lookup
CREATE TABLE dbo.channel_tech_lookup (
    tech_id INT IDENTITY(1,1) PRIMARY KEY,
    lookup_id INT NOT NULL,  -- holds id to gsm or lte cells
    tech_name NVARCHAR(20) NOT NULL UNIQUE
);

-- Base stations
CREATE TABLE dbo.base_stations (
    base_station_id INT IDENTITY(1,1) PRIMARY KEY,
    channel_number INT NOT NULL,
    base_station_name NVARCHAR(200) NOT NULL,
    tech_id INT NOT NULL,
    frequency_mhz FLOAT NOT NULL,
    arfcn INT NULL,
    mnc INT NULL,
    lac_tac INT NULL,
    bsic_psc_pci INT NULL,
    target_imsi NVARCHAR(64) NULL,
    uplink_frequency FLOAT NULL,
    downlink_frequency FLOAT NULL,
    name NVARCHAR(200) NULL,
    status NVARCHAR(20) NULL,
    operator_id INT NULL,
    band_id INT NULL,
    last_updated DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_base_stations_operators FOREIGN KEY (operator_id) REFERENCES dbo.operators(operator_id),
    CONSTRAINT FK_base_stations_frequency_bands FOREIGN KEY (band_id) REFERENCES dbo.frequency_bands(band_id),
    CONSTRAINT FK_base_stations_tech FOREIGN KEY (tech_id) REFERENCES dbo.channel_tech_lookup(tech_id)
);

-- GSM cells
CREATE TABLE dbo.gsm_cells (
    gsm_id INT IDENTITY(1,1) PRIMARY KEY,
    arfcn INT NOT NULL,
    bsic INT NULL,
    lac INT NULL,
    cell_id INT NOT NULL,
    mcc INT NULL,
    mnc INT NULL,
    rxlev FLOAT NULL,
    operator_id INT NULL,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_gsm_operator FOREIGN KEY (operator_id) REFERENCES dbo.operators(operator_id),
    CONSTRAINT FK_gsm_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);

-- LTE FDD cells
CREATE TABLE dbo.lte_fdd_cells (
    lte_fdd_id INT IDENTITY(1,1) PRIMARY KEY,
    band INT NOT NULL,
    earfcn INT NOT NULL,
    pci INT NULL,
    mcc INT NULL,
    mnc INT NULL,
    tac INT NULL,
    cell_identity BIGINT NULL,
    rsrp FLOAT NULL,
    rsrq FLOAT NULL,
    operator_id INT NULL,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_lte_fdd_operator FOREIGN KEY (operator_id) REFERENCES dbo.operators(operator_id),
    CONSTRAINT FK_lte_fdd_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);

-- LTE TDD cells
CREATE TABLE dbo.lte_tdd_cells (
    lte_tdd_id INT IDENTITY(1,1) PRIMARY KEY,
    band INT NOT NULL,
    earfcn INT NOT NULL,
    pci INT NULL,
    mcc INT NULL,
    mnc INT NULL,
    tac INT NULL,
    cell_identity BIGINT NULL,
    subframe_assignment INT NULL,
    special_subframe_pattern INT NULL,
    rsrp FLOAT NULL,
    rsrq FLOAT NULL,
    operator_id INT NULL,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_lte_tdd_operator FOREIGN KEY (operator_id) REFERENCES dbo.operators(operator_id),
    CONSTRAINT FK_lte_tdd_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);

-- Locations
CREATE TABLE dbo.locations (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    location_name NVARCHAR(200) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    latitude FLOAT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude FLOAT NULL CHECK (longitude BETWEEN -180 AND 180),
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- Device types
CREATE TABLE dbo.device_types (
    device_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(300) NULL
);

-- Devices
CREATE TABLE dbo.devices (
    device_id INT IDENTITY(1,1) PRIMARY KEY,
    device_name NVARCHAR(200) NOT NULL,
    device_type_id INT NULL,
    imei NVARCHAR(50) NULL UNIQUE,
    serial_number NVARCHAR(100) NULL UNIQUE,
    mac_address NVARCHAR(50) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_devices_device_types FOREIGN KEY (device_type_id) REFERENCES dbo.device_types(device_type_id)
);

-- IMSI targets
CREATE TABLE dbo.imsi_targets (
    imsi_target_id INT IDENTITY(1,1) PRIMARY KEY,
    description NVARCHAR(500) NULL,
    case_ref NVARCHAR(100) NULL,
    location_id INT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    CONSTRAINT FK_imsi_targets_users FOREIGN KEY (created_by) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_imsi_targets_location FOREIGN KEY (location_id) REFERENCES dbo.locations(location_id)
);

CREATE TABLE dbo.imsi_target_numbers (
    imsi_number_id INT IDENTITY(1,1) PRIMARY KEY,
    imsi_target_id INT NOT NULL,
    imsi NVARCHAR(64) NOT NULL,
    CONSTRAINT FK_imsi_numbers_target FOREIGN KEY (imsi_target_id) REFERENCES dbo.imsi_targets(imsi_target_id)
);

CREATE TABLE dbo.imsi_target_names (
    name_id INT IDENTITY(1,1) PRIMARY KEY,
    imsi_target_id INT NOT NULL,
    target_name NVARCHAR(200) NOT NULL,
    CONSTRAINT FK_imsi_names_target FOREIGN KEY (imsi_target_id) REFERENCES dbo.imsi_targets(imsi_target_id)
);

-- IMEI targets
CREATE TABLE dbo.imei_targets (
    imei_target_id INT IDENTITY(1,1) PRIMARY KEY,
    description NVARCHAR(500) NULL,
    case_ref NVARCHAR(100) NULL,
    location_id INT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    CONSTRAINT FK_imei_targets_users FOREIGN KEY (created_by) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_imei_targets_location FOREIGN KEY (location_id) REFERENCES dbo.locations(location_id)
);

CREATE TABLE dbo.imei_target_numbers (
    imei_number_id INT IDENTITY(1,1) PRIMARY KEY,
    imei_target_id INT NOT NULL,
    imei NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_imei_numbers_target FOREIGN KEY (imei_target_id) REFERENCES dbo.imei_targets(imei_target_id)
);

CREATE TABLE dbo.imei_target_names (
    name_id INT IDENTITY(1,1) PRIMARY KEY,
    imei_target_id INT NOT NULL,
    target_name NVARCHAR(200) NOT NULL,
    CONSTRAINT FK_imei_names_target FOREIGN KEY (imei_target_id) REFERENCES dbo.imei_targets(imei_target_id)
);

-- Whitelist
CREATE TABLE dbo.whitelist (
    whitelist_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NULL,
    description NVARCHAR(500) NULL,
    imei NVARCHAR(50) NULL,
    imsi NVARCHAR(64) NULL,
    device_id INT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    CONSTRAINT FK_whitelist_device FOREIGN KEY (device_id) REFERENCES dbo.devices(device_id),
    CONSTRAINT FK_whitelist_user FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);

-- Blacklist
CREATE TABLE dbo.blacklist (
    blacklist_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NULL,
    description NVARCHAR(500) NULL,
    imei NVARCHAR(50) NULL,
    imsi NVARCHAR(64) NULL,
    device_id INT NULL,
    reason NVARCHAR(500) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    CONSTRAINT FK_blacklist_device FOREIGN KEY (device_id) REFERENCES dbo.devices(device_id),
    CONSTRAINT FK_blacklist_user FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);

-- Task types
CREATE TABLE dbo.task_types (
    task_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(20) NOT NULL UNIQUE,
    description NVARCHAR(200) NULL
);

-- Tasks
CREATE TABLE dbo.tasks (
    task_id INT IDENTITY(1,1) PRIMARY KEY,
    task_type_id INT NOT NULL,
    tech_id INT NOT NULL,
    source NVARCHAR(100) NULL,
    dl INT NULL,
    ul INT NULL,
    ul_freq FLOAT NULL,
    band NVARCHAR(100) NULL,
    imei NVARCHAR(50) NULL,
    target_imsi NVARCHAR(64) NULL,
    user_id INT NULL,
    case_ref NVARCHAR(100) NULL,
    location_id INT NULL,
    action NVARCHAR(100) NULL,
    channel_id INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    status NVARCHAR(30) NULL,
    CONSTRAINT FK_tasks_base_station FOREIGN KEY (channel_id) REFERENCES dbo.base_stations(base_station_id),
    CONSTRAINT FK_tasks_location FOREIGN KEY (location_id) REFERENCES dbo.locations(location_id),
    CONSTRAINT FK_tasks_task_type FOREIGN KEY (task_type_id) REFERENCES dbo.task_types(task_type_id),
    CONSTRAINT FK_tasks_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_tasks_tech FOREIGN KEY (tech_id) REFERENCES dbo.channel_tech_lookup(tech_id)
);

-- Scan sessions and results
CREATE TABLE dbo.scan_sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    session_name NVARCHAR(200) NOT NULL,
    device_id INT NULL,
    location_id INT NULL,
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NULL,
    profile_id INT NULL,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_scan_sessions_device FOREIGN KEY (device_id) REFERENCES dbo.devices(device_id),
    CONSTRAINT FK_scan_sessions_location FOREIGN KEY (location_id) REFERENCES dbo.locations(location_id)
);

CREATE TABLE dbo.scan_results (
    result_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    channel_id INT NOT NULL,
    operator_id INT NULL,
    signal_strength FLOAT NULL,
    signal_quality FLOAT NULL,
    tmsi NVARCHAR(64) NULL,
    time_advance INT NULL,
    event_time DATETIME2 NOT NULL,
    additional_data NVARCHAR(MAX) NULL,
    CONSTRAINT FK_scan_results_session FOREIGN KEY (session_id) REFERENCES dbo.scan_sessions(session_id),
    CONSTRAINT FK_scan_results_base_station FOREIGN KEY (channel_id) REFERENCES dbo.base_stations(base_station_id),
    CONSTRAINT FK_scan_results_operator FOREIGN KEY (operator_id) REFERENCES dbo.operators(operator_id)
);


-- ========================
-- INDEXES
-- ========================
CREATE INDEX IX_scan_results_channel_event ON dbo.scan_results(channel_id, event_time);
CREATE INDEX IX_scan_results_session ON dbo.scan_results(session_id);
CREATE INDEX IX_tasks_case_ref ON dbo.tasks(case_ref);
CREATE INDEX IX_imsi_target_numbers_imsi ON dbo.imsi_target_numbers(imsi);
CREATE INDEX IX_imei_target_numbers_imei ON dbo.imei_target_numbers(imei);