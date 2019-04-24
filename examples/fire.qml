import QtQuick 2.7
import QtQuick.Particles 2.0

Item {
anchors { fill: parent }

function next(){ return false; }
function previous(){ return false; }

Rectangle {
width:  600
height: 200
color: "lightsteelblue"
anchors { centerIn: parent }
} // rect

ParticleSystem {
    anchors.fill: parent

    property alias emitterX: emitter.x
    property alias emitterY: emitter.y

    //property alias color: img.color
    property alias emitting: emitter.enabled


    ImageParticle {
        id: img
        //source: "file://usr/share/doc/qt/examples/quick/touchinteraction/multipointtouch/content/blur-circle.png"
        source: "file://home/sander/fast/programming/pres.io/img/rectangle.png"
        //colorVariation: 0.2
        //color: "#ff521d"
        //color: "#ff400f"
color: "yellow"
        alpha: 1
    }

/*
ItemParticle {
id: img2

property string color: "blue"

delegate: Rectangle {
 width: 10; height: 10;
color: "red"
opacity: 0.5
//color: "#00000" + Math.randInt()
}
}*/

    Emitter {
        id: emitter
width:  600
height: 100
x: 480
y: 300
//anchors { centerIn: parent }
        velocityFromMovement: 5
        emitRate: 800
        lifeSpan: 3000
        velocity: PointDirection{ x: 90; y: -90; xVariation: 0; yVariation: 0; }
        acceleration: PointDirection{ xVariation: 20; yVariation: 20; }
//        size: 51
//        sizeVariation: 53
//        endSize: 64

        size: 36
        sizeVariation: 2
        endSize: 3
    }


Affector {
anchors { fill: parent }
            onAffectParticles: {

                for (var i=0; i<particles.length; i++) {
                    var p = particles[i];

//console.info(particle.red, particle.green, particle.blue, particle.alpha);
p.red = 1;
p.green = p.lifeLeft() / p.lifeSpan;
p.blue = 0.2*p.lifeLeft() / p.lifeSpan;
p.update = true;

//console.info(p.t, p.lifeLeft(), p.lifeSpan, p.red, p.green, p.blue);
                }
            }  
}
} // psys


} // item
