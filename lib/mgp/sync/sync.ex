defmodule Mgp.Sync do
  use Task, restart: :permanent

  require Logger
  alias Mgp.Sync.ImportData

  @base_year 2016
  @remote_folder "/mnt/scl"

  # mkdir /mnt/scl
  # Add the following to /etc/fstab
  # //192.168.0.150/scl /mnt/scl cifs nouser,ro,iocharset=utf8,x-systemd.automount,_net_dev,noperm 0 0

  def start_link(_arg) do
    Task.start_link(__MODULE__, :sync, [])
  end

  def sync() do
    receive do
    after
      30_000 ->
        nil
        # TODO: UNCOMMENT LATER
        # rsync()
    end
  end

  def rsync() do
    # rsync payroll files to
    rsync_payroll_dbf_files()

    # Try and sync files from base fin year to now
    # But only on files that rsync was able to sync on
    # in order of base year and master dbfs first else whatever that got synced
    years = years_to_sync(@base_year)

    years_and_dbf_files =
      Enum.map(years, fn x -> %{year: x, dbf_files: get_dbf_files_to_rsync(x)} end)

    years_and_dbf_files |> Enum.map(fn x -> rsync_for_year(x) end)
    sync()
  end

  defp rsync_for_year(%{year: year, dbf_files: dbf_files}) do
    files = Map.values(dbf_files)

    case rsync_dbf_files(year, files) do
      {rsynced_files, 0} -> ImportData.populate(year, rsynced_files)
      {_, _} -> false
    end
  end

  defp rsync_dbf_files(year, files) do
    yy = String.slice(to_string(year), 2, 2)
    args = Enum.concat(["--timeout=60", "-av"], files)
    cmd = Enum.concat(args, [Path.join(ImportData.root_folder(), "/MGP#{yy}")])
    System.cmd("rsync", cmd)
  end

  defp years_to_sync(base_year) do
    today = Date.utc_today()
    year = today.year
    month = today.month

    case month >= 10 do
      true -> Enum.to_list(base_year..year)
      false -> Enum.to_list(base_year..(year - 1))
    end
  end

  defp get_dbf_files_to_rsync(year) do
    files = ImportData.generate_file_paths(@remote_folder, year)
    posts = ImportData.generate_postings_file_paths(@remote_folder, year)
    Map.merge(files, posts)
  end

  def rsync_payroll_dbf_files() do
    args =
      Enum.concat(["--timeout=60", "-av"], [
        "/mnt/scl/HPMG22/H1EMP.DBF",
        "/mnt/scl/HPMG22/H1DETPAY.DBF"
      ])

    cmd = Enum.concat(args, [Path.join(ImportData.root_folder(), "/HPMG18")])
    System.cmd("rsync", cmd)
  end
end
