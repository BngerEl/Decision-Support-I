using JuMP
using HiGHS
using Dates

TOURNOI_FOOT=Model(optimizer_with_attributes(HiGHS.Optimizer))

# Equipe 1: FCB		Bâle
# Equipe 2 : GC		Grasshopper
# Equipe 3 : LS		Lausanne
# Equipe 4 : FCL	Lucerne
# Equipe 5 : SERV	Genève
# Equipe 6 : SION	Sion
# Equipe 7 : STG	St Gall
# Equipe 8: FCZ		Zurich
# Equipe 9 : YB		Berne
# Equipe 10 : VA	Vaduz

equipes=["FCB ","GC  ","LS  ","FCL ","SERV ","SION ","STG ","FCZ ","YB  ","VA  "]


@variable(TOURNOI_FOOT,x[1:10,1:10,1:9],Bin)
# x_{i,j,k}=1 si l'équipe i joue à la maison contre l'équipe j au tour k

@variable(TOURNOI_FOOT,z[1:5],Bin)
@variable(TOURNOI_FOOT,z6a,Bin)
@variable(TOURNOI_FOOT,z6b,Bin)
@variable(TOURNOI_FOOT,z7,Bin)
@variable(TOURNOI_FOOT,z8,Bin)
@variable(TOURNOI_FOOT,z9[1:9],Bin)
@variable(TOURNOI_FOOT,z10[1:10],Bin)
@variable(TOURNOI_FOOT,z11[1:10,1:8],Bin)
@variable(TOURNOI_FOOT,z12,Bin)
@variable(TOURNOI_FOOT,z13[1:10,1:7],Bin)
@variable(TOURNOI_FOOT,z14[1:10,1:6],Bin)
@variable(TOURNOI_FOOT,z15[1:10,1:5],Bin)
# variables binaires de pénalité


@objective(TOURNOI_FOOT,Min,
4*z[1]+3*z[2]+3*z[3]+3*z[4]+20*z[5]+10*(z6a+z6b)+10*z7+10*z8
+12*sum(z9[k] for k in 1:9)
+5*sum(z10[i] for i in 1:10)
+10*sum(z11[i,k] for i in 1:10, k in 1:8)
+10*z12
+50*sum(z13[i,k] for i in 1:10, k in 1:7)
+40*sum(z14[i,k] for i in 1:10, k in 1:6)
+30*sum(z15[i,k] for i in 1:10, k in 1:5))


@constraint(TOURNOI_FOOT,contrainte0b[i=1:10, k=1:9],sum(x[i,j,k]+x[j,i,k] for j in 1:10)==1)
# chaque equipe joue exactement 1 match par tour
@constraint(TOURNOI_FOOT,contrainte0c[i=1:10, j=i+1:10],sum(x[i,j,k]+x[j,i,k] for k in 1:9)==1)
# chaque equipe joue contre chaque autre exactement 1 fois

@constraint(TOURNOI_FOOT,contrainte1,1-x[9,8,1]<=z[1])
# YB joue à domicile contre FCZ lors du premier tour.

@constraint(TOURNOI_FOOT,contrainte2,1-sum(x[2,j,2] for j in 1:10)<=z[2])
# GC joue à domicile lors du deuxième tour.

@constraint(TOURNOI_FOOT,contrainte3,1-sum(x[3,j,3] for j in 1:10)<=z[3])
# LS joue à domicile lors du troisième tour.

@constraint(TOURNOI_FOOT,contrainte4,1-sum(x[i,3,4] for i in 1:10)<=z[4])
# LS joue à l'extérieur lors du quatrième tour.

@constraint(TOURNOI_FOOT,contrainte5,1-x[3,5,2]<=z[5])
# LS joue à domicile contre SERV lors du deuxième tour.

@constraint(TOURNOI_FOOT,contrainte6a,x[3,8,3]+x[3,2,3]<=z6a)
@constraint(TOURNOI_FOOT,contrainte6b,x[3,8,4]+x[3,2,4]<=z6b)
# LS ne pourra pas jouer à domicile ni contre FCZ ni contre GC lors des troisième
# et quatrième tours.

@constraint(TOURNOI_FOOT,contrainte7,1-sum(x[5,j,5] for j in 1:10)<=z7)
# SERV doit jouer à domicile lors du cinquième tour.

@constraint(TOURNOI_FOOT,contrainte8,1-sum(x[i,6,5] for i in 1:10)<=z8)
# SION doit jouer à l'extérieur lors du cinquième tour.

@constraint(TOURNOI_FOOT,contrainte9a[k=1:9],sum(x[8,j,k]+x[2,j,k] for j in 1:10)<=1+z9[k])
# Quand FCZ joue à domicile lors d'un tour, alors GC doit jouer à l'extérieur lors
# de ce même tour et vice versa.

@constraint(TOURNOI_FOOT,contrainte10a[i=1:10],sum(x[i,j,1]+x[i,j,2] for j in 1:10)<=1+z10[i])
@constraint(TOURNOI_FOOT,contrainte10b[i=1:10],sum(x[j,i,1]+x[j,i,2] for j in 1:10)<=1+z10[i])
# Aucune équipe ne pourra jouer les deux premiers matchs (1er et 2ème tours) à domicile (HH).
# De même, aucune équipe ne pourra jouer les deux premiers matchs (1er et 2ème tours) à
# l'extérieur (AA). Donc aucun "break" n'est permis lors des deux premiers tours.

@constraint(TOURNOI_FOOT,contrainte11[i=1:10,k=1:8],x[i,2,k]+x[2,i,k]+x[i,8,k]+
x[8,i,k]+x[i,1,k]+x[1,i,k]+x[i,2,k+1]+x[2,i,k+1]+x[i,8,k+1]+x[8,i,k+1]+x[i,1,k+1]+x[1,i,k+1]<=1+z11[i,k])
# Quand une équipe joue contre une des équipes FCB, FCZ, GC lors d'un tour, alors
# elle ne pourra pas jouer contre une des ces équipes lors du tour suivant.

@constraint(TOURNOI_FOOT,constrainte12a,x[8,10,1]<=x[3,10,2]+z12)
@constraint(TOURNOI_FOOT,constrainte12b,x[3,10,1]<=x[8,10,2]+z12)
@constraint(TOURNOI_FOOT,constrainte12c[k=2:8],x[3,10,k]+x[8,10,k]-x[3,10,k-1]-x[8,10,k-1]<=x[3,10,k+1]+x[8,10,k+1]+z12)
# Quand VA joue à l'extérieur contre LS ou FCZ, alors VA doit jouer le tour suivant
# (si celui-ci existe) à l'extérieur contre l'autre des ces deux équipes LS, FCZ.

@constraint(TOURNOI_FOOT,constraint13a[i=1:10,k=1:7],sum(x[i,j,k]+x[i,j,k+1]+x[i,j,k+2] for j in 1:10)<=2+z13[i,k])
@constraint(TOURNOI_FOOT,constraint13b[i=1:10,k=1:7],sum(x[j,i,k]+x[j,i,k+1]+x[j,i,k+2] for j in 1:10)<=2+z13[i,k])
# Aucune équipe ne pourra jouer trois matchs consécutifs à domicile (HHH) ou trois
# matchs consécutifs  à l'extérieur (AAA). En d'autres mots, deux "breaks" consécutifs
# ne sont pas permis.

@constraint(TOURNOI_FOOT,constraint14a[i=1:10,k=1:6],sum(x[i,j,k]+x[i,j,k+1]+x[j,i,k+2]+x[j,i,k+3] for j in 1:10)<=3+z14[i,k])
@constraint(TOURNOI_FOOT,constraint14b[i=1:10,k=1:6],sum(x[j,i,k]+x[j,i,k+1]+x[i,j,k+2]+x[i,j,k+3] for j in 1:10)<=3+z14[i,k])
# Aucune équipe ne pourra jouer deux matchs consécutifs à domicile suivi de deux matchs
# consécutifs à l'extérieur (HHAA). De même, aucune équipe ne pourra jouer deux matchs
# consécutifs à l'extérieur  suivis de deux matchs consécutifs à domicile (AAHH).

@constraint(TOURNOI_FOOT,constraint15a[i=1:10,k=1:5],sum(x[i,j,k]+x[i,j,k+1]+x[j,i,k+2]+x[i,j,k+3]+x[i,j,k+4] for j in 1:10)<=4+z15[i,k])
@constraint(TOURNOI_FOOT,constraint15b[i=1:10,k=1:5],sum(x[j,i,k]+x[j,i,k+1]+x[i,j,k+2]+x[j,i,k+3]+x[j,i,k+4] for j in 1:10)<=4+z15[i,k])
# Aucune équipe ne pourra jouer deux matchs consécutifs à domicile suivis d'un match
# à l'extérieur, suivi de deux matchs consécutifs à domicile (HHAHH). De même, aucune
# équipe ne pourra jouer deux matchs consécutifs à l'extérieur suivis d'un match à domicile,
# suivis de deux matchs consécutifs à l'extérieur (AAHAA).


JuMP.optimize!(TOURNOI_FOOT)


for k in 1:9
    println("Tour ",k,":")
    for i in 1:10, j in 1:10
        if JuMP.value(x[i,j,k])==1
            println(equipes[i]," vs ",equipes[j])
        end
    end
    println()
end

for i in 1:5
    if JuMP.value(z[i])==1
        println("Contrainte ",i,": non satisfaite")
    end
end

if JuMP.value(z6a)==1 || JuMP.value(z6b)==1
    println("Contrainte 6: non satisfaite")
end

if JuMP.value(z7)==1
    println("Contrainte 7: non satisfaite")
end

if JuMP.value(z8)==1
    println("Contrainte 8: non satisfaite")
end

for k in 1:9
    if JuMP.value(z9[k])==1
        println("Contrainte 9: non satisfaite")
    end
end

for i in 1:10
    if JuMP.value(z10[i])==1
        println("Contrainte 10: non satisfaite")
    end
end

for i in 1:10
    for k in 1:8
        if JuMP.value(z11[i,k])==1
            println("Contrainte 11: non satisfaite")
        end
    end
end

if JuMP.value(z12)==1
    println("Contrainte 12: non satisfaite")
end

for i in 1:10
    for j in 1:7
        if JuMP.value(z13[i,j])==1
            println("Contrainte 13: non satisfaite")
        end
    end
    for j in 1:6
        if JuMP.value(z14[i,j])==1
            println("Contrainte 14: non satisfaite")
        end
    end
    for j in 1:5
        if JuMP.value(z15[i,j])==1
            println("Contrainte 15: non satisfaite")
        end
    end
end

println()
println("Pénalités totales: ", objective_value(TOURNOI_FOOT))