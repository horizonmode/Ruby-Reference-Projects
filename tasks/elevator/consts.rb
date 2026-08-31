module ElevatorConsts
  MIN_FLOOR = 1
  MAX_FLOOR = 10
  DIRECTIONS = %i[up down idle].freeze
  DOOR_STATUSES = %i[open closed].freeze
  SERVICE_STATUSES = %i[available out_of_service].freeze
end
