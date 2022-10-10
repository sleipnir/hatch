defmodule Hatch.PermitActor do
  @moduledoc """
  A permit is first *required* by an *authority*.

  Once paperwork has been prepared its *submitted* for approval to said authority.

  Depending on the authorities' decision the permit is rejected or approved.

  A permit can't be rejected/approved if it hasn't first been submitted.

  This is a basic state machine workflow modeling a typical approval process with basic invariants to uphold.
  """
  use SpawnSdk.Actor,
    abstract: true,
    state_type: Hatch.Permitting.Permit

  require Logger
  alias Hatch.PermitFlow

  alias Hatch.Permitting.{
    # commands
    RequirePermit,
    SubmitPermit,
    RejectPermit,
    ApprovePermit,
    # events
    PermitRequired,
    PermitSubmitted,
    PermitApproved,
    PermitRejected
  }

  @impl true
  def handle_command(
        {:require, %RequirePermit{} = cmd},
        %Context{} = ctx
      ) do
    Logger.info("Received Request: #{inspect(cmd)}. Context: #{inspect(ctx)}")

    permit = PermitFlow.init(cmd)

    event = permit |> Map.to_list() |> PermitRequired.new()

    %Value{}
    |> Value.of(event, permit)
    |> Value.reply!()
  end

  def handle_command(
        {:submit, %SubmitPermit{} = cmd},
        %Context{state: permit} = ctx
      ) do
    Logger.info("Received Request: #{inspect(cmd)}. Context: #{inspect(ctx)}")

    case PermitFlow.can_submit?(permit) do
      :ok ->
        submitted_permit = PermitFlow.submit(permit)

        event =
          PermitSubmitted.new(permit_id: permit.permit_id, submitted_on: permit.submitted_on)

        %Value{}
        |> Value.of(event, submitted_permit)
        |> Value.reply!()

      {:error, msg} ->
        %Value{}
        |> Value.of(msg, permit)
        |> Value.reply!()
    end
  end

  def handle_command(
        {:reject, %RejectPermit{} = cmd},
        %Context{state: permit} = ctx
      ) do
    Logger.info("Received Request: #{inspect(cmd)}. Context: #{inspect(ctx)}")

    case PermitFlow.can_reject?(permit) do
      :ok ->
        rejected_permit = PermitFlow.reject(permit, cmd.rejection_reason)

        event =
          PermitRejected.new(
            permit_id: permit.permit_id,
            rejected_on: permit.rejected_on,
            rejection_reason: permit.rejection_reason
          )

        %Value{}
        |> Value.of(event, rejected_permit)
        |> Value.reply!()

      {:error, msg} ->
        %Value{}
        |> Value.of(msg, permit)
        |> Value.reply!()
    end
  end

  def handle_command(
        {:approve, %ApprovePermit{} = cmd},
        %Context{state: permit} = ctx
      ) do
    Logger.info("Received Request: #{inspect(cmd)}. Context: #{inspect(ctx)}")

    case PermitFlow.can_approve?(permit) do
      :ok ->
        approved_permit = PermitFlow.approve(permit)

        event =
          PermitApproved.new(
            permit_id: permit.permit_id,
            approved_on: permit.approved_on
          )

        %Value{}
        |> Value.of(event, approved_permit)
        |> Value.reply!()

      {:error, msg} ->
        %Value{}
        |> Value.of(msg, permit)
        |> Value.reply!()
    end
  end
end
