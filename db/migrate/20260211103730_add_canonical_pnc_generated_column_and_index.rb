# frozen_string_literal: true

class AddCanonicalPncGeneratedColumnAndIndex < ActiveRecord::Migration[8.0]
  # Concurrent index creation cannot run inside a transaction
  disable_ddl_transaction!

  def up
    # 1) Add the stored generated column `canonical_pnc`
    #    Expression equals your canonicalizer:
    #      year (YY or YYYY before first separator)
    #      || lpad(remaining digits after removing that year, 7, '0')
    #      || final letter (uppercased)
    execute <<~SQL
      ALTER TABLE people
      ADD COLUMN canonical_pnc TEXT GENERATED ALWAYS AS (
        (
          -- Extract YEAR: 2 or 4 digits before the first separator
          (regexp_match(upper(people.police_national_computer), '^(\\d{2}|\\d{4})[ /.-]'))[1]
        )
        ||
        lpad(
          -- Remaining digits after removing YEAR from the front of all digits
          regexp_replace(
            regexp_replace(upper(people.police_national_computer), '\\D', '', 'g'),
            '^' || (regexp_match(upper(people.police_national_computer), '^(\\d{2}|\\d{4})[ /.-]'))[1],
            ''
          ),
          7,
          '0'
        )
        ||
        -- Final letter, uppercased (take the last letter present)
        right(regexp_replace(upper(people.police_national_computer), '[^A-Z]', '', 'g'), 1)
      ) STORED
    SQL

    # 2) Create a concurrent index on the generated column
    add_index :people, :canonical_pnc,
              name: "index_people_on_canonical_pnc",
              using: :btree,
              algorithm: :concurrently
  end

  def down
    # Drop the index first (concurrently)
    remove_index :people, name: "index_people_on_canonical_pnc", algorithm: :concurrently

    # Drop the generated column
    remove_column :people, :canonical_pnc
  end
end