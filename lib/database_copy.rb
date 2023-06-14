# frozen_string_literal: true

require "pg"
require "tty-spinner"
require "pastel"

require_relative "database_copy/version"

module DatabaseCopy
  TABLES = [:accessory_applicables, :accessory_results, :action_text_rich_texts, :active_storage_attachments, :attachments, :active_storage_blobs, :catalogs, :contract_templates, :credits, :crowdfunding_contract_templates, :contracts, :credit_applications, :crowdfunding_contracts, :crowdfunding_crowdfunds, :crowdfunding_funds, :crowdfunding_investors, :crowdfunding_movements, :crowdfunding_settings, :events, :expenses, :holidays, :incomes, :customers, :movements, :installment_plans, :installments, :product_accessories, :payments, :promotions, :references, :score_flows, :users, :score_component_results, :score_components, :accessories, :products]
  EXCLUDE_COLUMNS = [:updated_at, :uid, :organization_id, :uuid]

  class Error < StandardError; end

  module ImportUI
    @@spinner = nil

    def self.start(message)
      @@spinner ||= TTY::Spinner.new(message)
      @@spinner&.auto_spin
    end

    def self.error(message)
      @@spinner&.error(message)
    end

    def self.clear_line
      @@spinner&.clear_line
    end

    def self.finish(message = "")
      @@spinner&.success(message)
    end

    def self.info(message)
      clear_line
      puts message
    end

    def self.warn(message)
      clear_line
      puts color.yellow message
    end

    def self.color
      @@color ||= Pastel.new
    end
  end

  class Executor
    def initialize(source_db:, target_db:)
      @source_db = source_db
      @target_db = target_db
    end

    def copy_database
      copy_tables
    end

    private

    def copy_tables
      source_conn = connect_to_database(@source_db)
      target_conn = connect_to_database(@target_db)

      TABLES.each do |table_name|
        create_table(source_conn, target_conn, table_name.to_s)
        copy_table(source_conn, target_conn, table_name.to_s)
      end

      source_conn.close
      target_conn.close
    end

    def create_table(source_conn, target_conn, table_name)
      ddl = generate_create_table_command(source_conn, table_name)

      target_conn.exec(ddl.sub(/CREATE TABLE/, "CREATE TABLE IF NOT EXISTS"))
    end

    def copy_table(source_conn, target_conn, table_name)
      ImportUI.info("Copying table #{table_name}")
      columns = table_columns(source_conn, table_name)

      data = source_conn.exec("SELECT #{columns} FROM #{source_conn.escape_identifier(table_name)}")
      data.each do |row|
        row_columns = columns.split(",").map do |column|
          value = row[column.strip]

          if value.nil? || value == ""
            "null"
          elsif numeric_value?(value)
            value
          elsif value == "t"
            true
          elsif value == "f"
            false
          else
            "'#{value.gsub("'", "''")}'"
          end
        end.join(", ")

        sql = "INSERT INTO #{table_name} (#{columns}) VALUES (#{row_columns})"
        target_conn.exec(sql)
      end

      ImportUI.info("Inserted #{data.count} records.")
    end

    def table_columns(conn, table_name)
      excluded = EXCLUDE_COLUMNS.map { |c| "'#{c}'" }.join(", ")
      result = conn.exec_params("SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1 AND column_name NOT IN (#{excluded})", [table_name])

      columns = result.map { |row| row["column_name"] }
      columns.join(", ")
    end

    def connect_to_database(database)
      PG::Connection.new(database)
    end

    def generate_create_table_command(conn, table_name)
      result = conn.exec_params("SELECT pg_get_serial_sequence($1, column_name) AS serial_sequence, * FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1 ORDER BY ordinal_position", [table_name])

      columns = result.map do |row|
        if !EXCLUDE_COLUMNS.map(&:to_s).include?(row["column_name"])
          column_name = row["column_name"]
          default_value = (row["column_default"] && column_name != "id") ? "DEFAULT #{row["column_default"]}" : ""
          data_type = cast_array(row["data_type"], default_value)
          null_constraint = (row["is_nullable"] == "NO") ? "NOT NULL" : ""
          serial_constraint = (row["serial_sequence"] && column_name != "id") ? "DEFAULT nextval('#{row["serial_sequence"]}'::regclass)" : ""

          "#{conn.escape_identifier(column_name)} #{data_type} #{default_value} #{null_constraint} #{serial_constraint}"
        end
      end

      primary_key = get_primary_key(conn, table_name)
      primary_key_clause = primary_key ? ", PRIMARY KEY (#{primary_key})" : ""

      "CREATE TABLE #{conn.escape_identifier(table_name)} (\n  #{columns.compact.join(",\n  ")}#{primary_key_clause}\n);"
    end

    def cast_array(data_type, default_value)
      return data_type if data_type != "ARRAY"

      if default_value.include?("integer")
        "integer[]"
      elsif default_value.include?("text")
        "text[]"
      else
        default_value
      end
    end

    def get_primary_key(conn, table_name)
      result = conn.exec_params("SELECT a.attname
                            FROM   pg_index i
                            JOIN   pg_attribute a ON a.attrelid = i.indrelid
                                               AND a.attnum = ANY(i.indkey)
                            WHERE  i.indrelid = $1::regclass
                            AND    i.indisprimary;", [table_name])

      result.map { |row| conn.escape_identifier(row["attname"]) }.join(", ")
    end

    def numeric_value?(value)
      !!value.match(/\A[+-]?\d+(\.\d+)?\z/)
    end
  end
end
