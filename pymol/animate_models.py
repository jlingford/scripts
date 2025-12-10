def animate_models(session, duration=1.0, cycles=5):
    """Animate showing/hiding models in sequence"""
    from chimerax.core.commands import run
    from chimerax.core.tasks import Task

    models = session.models.list()
    if not models:
        return

    def show_next_model(task, cycle, model_index):
        if cycle >= cycles:
            return

        # Hide all models
        run(session, "hide models")

        # Show current model
        current_model = models[model_index]
        run(session, f"show #{current_model.id}")

        # Schedule next model
        next_model = (model_index + 1) % len(models)
        next_cycle = cycle + (1 if next_model == 0 else 0)

        session.ui.timer.single_shot(
            duration * 1000, lambda: show_next_model(task, next_cycle, next_model)
        )

    # Start the animation
    task = Task("Model Animation", session)
    show_next_model(task, 0, 0)


# Run the animation
animate_models(session, duration=2.0, cycles=3)
