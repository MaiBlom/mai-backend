defmodule Helpers.Hash do

  def hash(salt, string) do
    hashed_string = :crypto.pbkdf2_hmac(:sha512, string, salt, 10000, 128)
    {:ok, hashed_string}
  end
end
