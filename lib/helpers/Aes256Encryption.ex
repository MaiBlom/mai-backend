defmodule Helpers.Aes256 do
  @block_size 16
  @key System.get_env("AES_ENCRYPTION_KEY")

  def encrypt(plaintext) do
    key = Base.decode16!(@key)
    iv = :crypto.strong_rand_bytes(16)
    plaintext = pad(plaintext, @block_size)

    ciphertext = :crypto.crypto_one_time(:aes_256_cbc, key, iv, plaintext, true)
    %{pw: Base.encode32(ciphertext), iv: Base.encode16(iv)}
  end

  def decrypt(ciphertext, iv) do
    key = Base.decode16!(@key)

    plaintext = :crypto.crypto_one_time(:aes_256_cbc, key, iv, ciphertext, false)
    unpad(plaintext)
  end

  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
end
