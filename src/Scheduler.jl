module Scheduler

export PQScheduler, isempty, schedule!, time_now, time_next, schedule_in!, next!, upto!, unschedule!


using DataStructures

struct Item{OBJ, FUN}
	obj :: OBJ
	fun :: FUN
end

exec(it :: Item{OBJ, FUN}) where {OBJ, FUN} = it.fun(obj)


mutable struct PQScheduler{TIME}
	queue :: PriorityQueue{Any, TIME}
	actions :: Dict{Any, Function}
	now :: TIME
end

PQScheduler{TIME}() where {TIME} = PQScheduler{TIME}(
	PriorityQueue{Any, TIME}(), Dict{Any, Function}(), TIME(0))


Base.isempty(scheduler::PQScheduler{TIME}) where {TIME} = isempty(scheduler.queue)

"add a single item"
function schedule!(fun, obj, at, scheduler)
	scheduler.queue[obj] = at
	scheduler.actions[obj] = fun
#	println("<- ", at)
end


time_now(scheduler) = scheduler.now
time_next(scheduler) = isempty(scheduler) ? scheduler.now : peek(scheduler.queue)[2]


"add a single item at `wait` time from now"
function schedule_in!(fun, obj, wait, scheduler)
	t = time_now(scheduler) + wait
	schedule!(fun, obj, t, scheduler)
end


"run the next action"
function next!(scheduler)
#	println("! ", scheduler.now)

	if isempty(scheduler)
		return
	end

	obj, time = peek(scheduler.queue)

	scheduler.now = time
	dequeue!(scheduler.queue)
	fun = scheduler.actions[obj]
	delete!(scheduler.actions, obj)
	fun(obj)
end

# we could implement this using repeated calls to next but that
# would require redundant calls to peek
"run actions up to `time`"
function upto!(scheduler, atime)
#	println("! ", scheduler.now, " ... ", time)

	while !isempty(scheduler)
		obj, time = peek(scheduler.queue)

		if time > atime
			scheduler.now = atime
			break
		end

		scheduler.now = time
		dequeue!(scheduler.queue)
		fun = scheduler.actions[obj]
		delete!(scheduler.actions, obj)
		fun(obj)
	end

	scheduler
end

function unschedule!(scheduler, obj::Any)
	delete!(scheduler.queue, obj)
	delete!(scheduler.actions, obj)
end

end
