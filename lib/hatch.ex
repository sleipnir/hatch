defmodule Hatch do
  @moduledoc """
  Hatching new schemes with Eigr & Spawn.
  """
  alias SpawnSdk.System.SpawnSystem

  alias Hatch.Permitting.{
    RequirePermit,
    SubmitPermit,
    RejectPermit,
    ApprovePermit
  }

  alias Hatch.PermitActor

  def require_permit(params \\ %{}) do
    permit_id = Uniq.UUID.uuid4()
    params = Map.merge(params, %{permit_id: permit_id})

    with %RequirePermit{} = cmd <- RequirePermit.new(params),
         {:ok, _} <- SpawnSdk.spawn_actor(permit_id, system: "spawn-system", actor: PermitActor) do
      SpawnSystem.invoke(permit_id, system: "spawn-system", command: :require, payload: cmd)
    end
  end

  def submit_permit(permit_id) do
    with %SubmitPermit{} = cmd <- SubmitPermit.new(permit_id: permit_id) do
      SpawnSdk.invoke(
        permit_id,
        ref: PermitActor,
        system: "spawn-system",
        command: :submit,
        payload: cmd
      )
    end
  end

  def reject_permit(permit_id, rejection_reason) do
    with %RejectPermit{} = cmd <-
           RejectPermit.new(permit_id: permit_id, rejection_reason: rejection_reason) do
      SpawnSdk.invoke(
        permit_id,
        ref: PermitActor,
        system: "spawn-system",
        command: :reject,
        payload: cmd
      )
    end
  end

  def approve_permit(permit_id) do
    with %ApprovePermit{} = cmd <- ApprovePermit.new(permit_id: permit_id) do
      SpawnSdk.invoke(
        permit_id,
        ref: PermitActor,
        system: "spawn-system",
        command: :approve,
        payload: cmd
      )
    end
  end
end
