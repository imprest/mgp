defmodule Mgp.AccountsTest do
  use Mgp.DataCase

  alias Mgp.Accounts

  describe "pdcs" do
    alias Mgp.Accounts.Pdc

    @valid_attrs %{amount: "some amount", cheque: "some cheque", date: ~D[2010-04-17], lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu"}
    @update_attrs %{amount: "some updated amount", cheque: "some updated cheque", date: ~D[2011-05-18], lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu"}
    @invalid_attrs %{amount: nil, cheque: nil, date: nil, lmd: nil, lmt: nil, lmu: nil}

    def pdc_fixture(attrs \\ %{}) do
      {:ok, pdc} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_pdc()

      pdc
    end

    test "list_pdcs/0 returns all pdcs" do
      pdc = pdc_fixture()
      assert Accounts.list_pdcs() == [pdc]
    end

    test "get_pdc!/1 returns the pdc with given id" do
      pdc = pdc_fixture()
      assert Accounts.get_pdc!(pdc.id) == pdc
    end

    test "create_pdc/1 with valid data creates a pdc" do
      assert {:ok, %Pdc{} = pdc} = Accounts.create_pdc(@valid_attrs)
      assert pdc.amount == "some amount"
      assert pdc.cheque == "some cheque"
      assert pdc.date == ~D[2010-04-17]
      assert pdc.lmd == ~D[2010-04-17]
      assert pdc.lmt == ~T[14:00:00.000000]
      assert pdc.lmu == "some lmu"
    end

    test "create_pdc/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_pdc(@invalid_attrs)
    end

    test "update_pdc/2 with valid data updates the pdc" do
      pdc = pdc_fixture()
      assert {:ok, pdc} = Accounts.update_pdc(pdc, @update_attrs)
      assert %Pdc{} = pdc
      assert pdc.amount == "some updated amount"
      assert pdc.cheque == "some updated cheque"
      assert pdc.date == ~D[2011-05-18]
      assert pdc.lmd == ~D[2011-05-18]
      assert pdc.lmt == ~T[15:01:01.000000]
      assert pdc.lmu == "some updated lmu"
    end

    test "update_pdc/2 with invalid data returns error changeset" do
      pdc = pdc_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_pdc(pdc, @invalid_attrs)
      assert pdc == Accounts.get_pdc!(pdc.id)
    end

    test "delete_pdc/1 deletes the pdc" do
      pdc = pdc_fixture()
      assert {:ok, %Pdc{}} = Accounts.delete_pdc(pdc)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_pdc!(pdc.id) end
    end

    test "change_pdc/1 returns a pdc changeset" do
      pdc = pdc_fixture()
      assert %Ecto.Changeset{} = Accounts.change_pdc(pdc)
    end
  end
end
