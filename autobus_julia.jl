using JuMP
using Cbc

autobus=Model(optimizer_with_attributes(Cbc.Optimizer))

@variable(autobus,x[1:7]>=0,Int)

@objective(autobus,Min,sum(x[i] for i in 1:7))

@constraint(autobus,Lundi,x[1]+x[4]+x[5]+x[6]+x[7]>=14)
@constraint(autobus,Mardi,x[1]+x[2]+x[5]+x[6]+x[7]>=12)
@constraint(autobus,Mercredi,x[1]+x[2]+x[3]+x[6]+x[7]>=18)
@constraint(autobus,Jeudi,x[1]+x[2]+x[3]+x[4]+x[7]>=16)
@constraint(autobus,Vendredi,x[1]+x[2]+x[3]+x[4]+x[5]>=15)
@constraint(autobus,Samedi,x[2]+x[3]+x[4]+x[5]+x[6]>=16)
@constraint(autobus,Dimanche,x[3]+x[4]+x[5]+x[6]+x[7]>=19)

JuMP.optimize!(autobus)

println(autobus)

for i in 1:7
    println("Nombre de chauffeurs selon le plan P",i,": ",JuMP.value(x[i]))
end

println("Nombre total de chauffeurs: ",objective_value(autobus))